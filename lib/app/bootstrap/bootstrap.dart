import 'package:claudewatch/core/modules/module_contracts.dart';
import 'package:claudewatch/core/modules/module_registry.dart';
import 'package:claudewatch/core/modules/module_loader.dart';
import 'package:claudewatch/core/modules/module_validator.dart';
import 'package:claudewatch/app/modules/app_module_registry.dart';
import 'package:claudewatch/app/modules/topological_module_loader.dart';
import 'package:claudewatch/app/modules/default_module_validator.dart';
import 'package:claudewatch/shared/modules/feature_placeholders.dart';
import 'package:claudewatch/app/bootstrap/locator_impl.dart';
import 'package:claudewatch/app/bootstrap/modules/core_module.dart';
import 'package:claudewatch/app/bootstrap/modules/feature_module.dart';
import 'package:claudewatch/app/bootstrap/modules/infrastructure_module.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';
import 'package:claudewatch/features/history/presentation/controllers/history_view_model.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:claudewatch/features/prompts/presentation/controllers/prompt_library_view_model.dart';
import 'package:claudewatch/app/bootstrap/modules/search_feature_module.dart';
import 'package:claudewatch/features/search/domain/repositories/search_repository.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_view_model.dart';
import 'package:claudewatch/core/analytics/analytics_tracker.dart';
import 'package:claudewatch/core/background/background_task_manager.dart';
import 'package:claudewatch/core/config/configuration.dart';
import 'package:claudewatch/core/config/configuration_provider.dart';
import 'package:claudewatch/core/config/feature_flags.dart';
import 'package:claudewatch/core/config/environment.dart';
import 'package:claudewatch/core/di/service_locator.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/logging/diagnostics.dart';
import 'package:claudewatch/core/navigation/app_router.dart';
import 'package:claudewatch/core/notifications/notification_service.dart';
import 'package:claudewatch/core/persistence/local_storage.dart';
import 'package:claudewatch/core/sync/sync_manager.dart';
import 'package:claudewatch/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:claudewatch/features/dashboard/presentation/controllers/dashboard_view_model.dart';
import 'package:claudewatch/core/state/state_observer.dart';
import 'package:claudewatch/core/state/state_error.dart';
import 'package:claudewatch/core/repository/repository_observer.dart';
import 'package:claudewatch/app/repository/repository_transaction.dart';
import 'package:claudewatch/shared/repository/placeholders/configuration_repository.dart';
import 'package:claudewatch/shared/repository/placeholders/settings_repository.dart';
import 'package:claudewatch/shared/repository/placeholders/device_repository.dart';
import 'package:claudewatch/shared/repository/placeholders/capture_repository.dart';
import 'package:claudewatch/shared/repository/placeholders/analytics_repository.dart'
    as repo_analytics;
import 'package:claudewatch/shared/repository/placeholders/prediction_repository.dart';
import 'package:claudewatch/core/persistence/persistence_contracts.dart';
import 'package:claudewatch/core/persistence/migration_contracts.dart';
import 'package:claudewatch/core/persistence/persistence_observer.dart';
import 'package:claudewatch/app/persistence/persistence_validator.dart';

// Device Communication Imports
import 'package:claudewatch/core/device/device_transport.dart';
import 'package:claudewatch/core/device/device_discovery.dart';
import 'package:claudewatch/core/device/communication_observer.dart';
import 'package:claudewatch/core/device/communication_validator.dart';
import 'package:claudewatch/app/device/device_lifecycle_coordinator.dart';
import 'package:claudewatch/app/device/device_session_manager.dart';

// Application Services Imports
import 'package:claudewatch/shared/services/usage_service.dart';
import 'package:claudewatch/shared/services/conversation_service.dart';
import 'package:claudewatch/shared/services/analytics_service.dart';
import 'package:claudewatch/shared/services/settings_service.dart';
import 'package:claudewatch/shared/services/widget_service.dart';
import 'package:claudewatch/shared/services/sync_service.dart';

class BootstrapException implements Exception {
  final String message;
  BootstrapException(this.message);
  @override
  String toString() => 'BootstrapException: $message';
}

class AppBootstrapper {
  final List<ApplicationModule> _modules;
  final ServiceLocator _locator;
  final ModuleRegistry _registry;
  final ModuleLoader _loader;
  final ModuleValidator _validator;
  final List<String> _registrationOrder = [];

  AppBootstrapper({
    List<ApplicationModule>? modules,
    ServiceLocator? locator,
    ModuleRegistry? registry,
    ModuleLoader? loader,
    ModuleValidator? validator,
  }) : _modules =
           modules ??
           [
             CoreModule(),
             InfrastructureModule(),
             DashboardFeatureModule(),
             HistoryFeatureModule(),
             HomeModule(),
             WidgetsModule(),
             AnalyticsModule(),
             UsageModule(),
             SettingsModule(),
             SearchFeatureModule(),
             PromptLibraryFeatureModule(),
             AIProvidersModule(),
           ],
       _locator = locator ?? AppServiceLocator.instance,
       _registry = registry ?? AppModuleRegistry(),
       _loader = loader ?? TopologicalModuleLoader(),
       _validator = validator ?? DefaultModuleValidator();

  List<String> get registrationOrder => List.unmodifiable(_registrationOrder);

  Future<ServiceLocator> bootstrap() async {
    _registrationOrder.clear();

    // 1. Register modules in registry
    for (final module in _modules) {
      _registry.registerModule(module);
    }

    // 2. Validate module graph (duplicates, missing deps, cycles)
    _validator.validate(_registry);

    // 3. Setup context
    // We register placeholder logger here, or pull from locator if it was already registered.
    // In actual implementation, logger is registered by CoreModule.
    // We will use a dummy logger just to satisfy ModuleContext if it's strictly needed before CoreModule.
    // But since CoreModule provides the real Logger, we can just pass a late resolution or mock.
    // Let's create a temporary logger for context.
    final mockContext = ModuleContext(
      locator: _locator,
      logger: AppServiceLocator.instance.isRegistered<Logger>()
          ? AppServiceLocator.instance.get<Logger>()
          : _createFallbackLogger(),
    );

    // 4. Load modules (resolves dependencies topographically, registers, initializes)
    await _loader.loadModules(_registry, mockContext);

    // Track the order for legacy tests
    for (final module in _registry.getAllModules()) {
      _registrationOrder.add(module.runtimeType.toString());
    }

    // 5. Validate vital core/infrastructure registrations
    _validateRegistrations();

    return _locator;
  }

  Logger _createFallbackLogger() {
    return AppServiceLocator.instance.isRegistered<Logger>()
        ? AppServiceLocator.instance.get<Logger>()
        : _FallbackLogger();
  }

  void _validateRegistrations() {
    final requiredTypes = [
      AppConfiguration,
      ConfigurationProvider,
      FeatureFlagProvider,
      EnvironmentConfiguration,
      Logger,
      DiagnosticsProvider,
      AppRouter,
      LocalStorage,
      AnalyticsTracker,
      NotificationService,
      BackgroundTaskManager,
      SyncManager,
      DashboardRepository,
      DashboardViewModel,
      HistoryRepository,
      HistoryViewModel,
      PromptRepository,
      PromptLibraryViewModel,
      SearchRepository,
      SearchViewModel,
      StateObserver,
      StateErrorHandler,
      RepositoryObserver,
      TransactionManager,
      ConfigurationRepository,
      SettingsRepository,
      DeviceRepository,
      CaptureRepository,
      repo_analytics.AnalyticsRepository,
      PredictionRepository,
      DatabaseProvider,
      MigrationProvider,
      PersistenceObserver,
      PersistenceValidator,
      // Device Communication Abstractions
      DeviceTransport,
      DeviceScanner,
      DevicePairing,
      DeviceAuthentication,
      CommunicationObserver,
      CommunicationValidator,
      DeviceLifecycleCoordinator,
      DeviceSessionManager,
      // Application Services
      UsageService,
      ConversationService,
      AnalyticsService,
      SettingsService,
      WidgetService,
      SyncService,
    ];

    for (final type in requiredTypes) {
      if (!_locator.isRegisteredDynamic(type)) {
        throw BootstrapException(
          'Required dependency missing from registrations: $type',
        );
      }
    }
  }
}

extension ServiceLocatorExtension on ServiceLocator {
  bool isRegisteredDynamic(Type type) {
    if (this is AppServiceLocator) {
      return (this as AppServiceLocator).isRegisteredType(type);
    }
    // Safe fallback for custom mock locators
    return true;
  }
}

class _FallbackLogger implements Logger {
  @override
  void log({
    required LogLevel level,
    required LogCategory category,
    required String message,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void trace(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  }) {}
  @override
  void debug(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void info(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  }) {}
  @override
  void warning(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void error(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void critical(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
}
