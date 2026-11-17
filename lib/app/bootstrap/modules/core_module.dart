import 'package:claudewatch/core/modules/module_contracts.dart';
import 'package:claudewatch/app/bootstrap/modules/placeholder_services.dart';
import 'package:claudewatch/core/config/configuration.dart';
import 'package:claudewatch/core/config/configuration_provider.dart';
import 'package:claudewatch/core/config/feature_flags.dart';
import 'package:claudewatch/core/config/environment.dart';
import 'package:claudewatch/shared/config/mock_configuration.dart';
import 'package:claudewatch/app/config/memory_configuration_provider.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/logging/diagnostics.dart';
import 'package:claudewatch/app/logging/app_logger_impl.dart';
import 'package:claudewatch/app/logging/console_log_sink.dart';
import 'package:claudewatch/shared/logging/mock_logging.dart';
import 'package:claudewatch/app/logging/simple_diagnostics_provider.dart';
import 'package:claudewatch/core/state/state_error.dart';
import 'package:claudewatch/core/state/state_observer.dart';
import 'package:claudewatch/core/repository/repository_observer.dart';
import 'package:claudewatch/app/repository/repository_transaction.dart';
import 'package:claudewatch/core/persistence/persistence_contracts.dart';
import 'package:claudewatch/core/persistence/migration_contracts.dart';
import 'package:claudewatch/core/persistence/persistence_observer.dart';
import 'package:claudewatch/app/persistence/persistence_validator.dart';
import 'package:claudewatch/shared/persistence/placeholders/placeholder_persistence_services.dart';

// Device Communication Imports
import 'package:claudewatch/core/device/device_transport.dart';
import 'package:claudewatch/core/device/device_discovery.dart';
import 'package:claudewatch/core/device/communication_observer.dart';
import 'package:claudewatch/core/device/communication_validator.dart';
import 'package:claudewatch/app/device/device_lifecycle_coordinator.dart';
import 'package:claudewatch/app/device/device_session_manager.dart';
import 'package:claudewatch/shared/device/mock_device_transport.dart';
import 'package:claudewatch/shared/device/mock_device_discovery.dart';
import 'package:claudewatch/shared/device/mock_communication_observer.dart';
import 'package:claudewatch/shared/device/mock_communication_validator.dart';

// Application Services Imports
import 'package:claudewatch/shared/services/usage_service.dart';
import 'package:claudewatch/shared/services/conversation_service.dart';
import 'package:claudewatch/shared/services/analytics_service.dart';
import 'package:claudewatch/shared/services/settings_service.dart';
import 'package:claudewatch/shared/services/widget_service.dart';
import 'package:claudewatch/shared/services/sync_service.dart';

class CoreModule extends ApplicationModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'core.infrastructure',
    name: 'Core Infrastructure',
    version: '1.0.0',
    dependencies: [],
  );

  @override
  void register(ModuleContext context) {
    final locator = context.locator;
    locator.registerLazySingleton<EnvironmentConfiguration>(
      () => MockEnvironmentConfiguration(AppEnvironment.development),
    );
    locator.registerLazySingleton<ConfigurationProvider>(
      () => MemoryConfigurationProvider(
        environment: locator.get<EnvironmentConfiguration>(),
      ),
    );
    locator.registerLazySingleton<FeatureFlagProvider>(
      () => FeatureFlagProviderImpl(locator.get<ConfigurationProvider>()),
    );
    locator.registerLazySingleton<AppConfiguration>(
      () => AppConfigurationImpl(
        provider: locator.get<ConfigurationProvider>(),
        featureFlagProvider: locator.get<FeatureFlagProvider>(),
      ),
    );
    locator.registerLazySingleton<DiagnosticsProvider>(
      () => SimpleDiagnosticsProvider(),
    );
    locator.registerLazySingleton<Logger>(() {
      final config = MockLoggingConfiguration();
      config.activeSinks.add(ConsoleLogSink());
      return AppLoggerImpl(configuration: config);
    });
    locator.registerLazySingleton<StateObserver>(
      () => PlaceholderStateObserver(),
    );
    locator.registerLazySingleton<StateErrorHandler>(
      () => PlaceholderStateErrorHandler(),
    );
    locator.registerLazySingleton<RepositoryObserver>(
      () => PlaceholderRepositoryObserver(),
    );
    locator.registerLazySingleton<TransactionManager>(
      () => PlaceholderTransactionManager(),
    );

    // Persistence Layer Placeholders
    locator.registerLazySingleton<DatabaseProvider>(
      () => PlaceholderDatabaseProvider(),
    );
    locator.registerLazySingleton<MigrationProvider>(
      () => PlaceholderMigrationProvider(),
    );
    locator.registerLazySingleton<PersistenceObserver>(
      () => PlaceholderPersistenceObserver(),
    );
    locator.registerLazySingleton<PersistenceValidator>(
      () => PlaceholderPersistenceValidator(),
    );

    // Device Communication Registrations
    locator.registerLazySingleton<DeviceTransport>(() => MockDeviceTransport());
    locator.registerLazySingleton<DeviceScanner>(() => MockDeviceScanner());
    locator.registerLazySingleton<DevicePairing>(() => MockDevicePairing());
    locator.registerLazySingleton<DeviceAuthentication>(
      () => MockDeviceAuthentication(),
    );
    locator.registerLazySingleton<CommunicationObserver>(
      () => MockCommunicationObserver(),
    );
    locator.registerLazySingleton<CommunicationValidator>(
      () => MockCommunicationValidator(),
    );
    locator.registerLazySingleton<DeviceLifecycleCoordinator>(
      () => DeviceLifecycleCoordinator(),
    );
    locator.registerLazySingleton<DeviceSessionManager>(
      () => DeviceSessionManager(),
    );

    // Application Services Registrations
    locator.registerLazySingleton<UsageService>(() => UsageService());
    locator.registerLazySingleton<ConversationService>(
      () => ConversationService(),
    );
    locator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
    locator.registerLazySingleton<SettingsService>(() => SettingsService());
    locator.registerLazySingleton<WidgetService>(() => WidgetService());
    locator.registerLazySingleton<SyncService>(() => SyncService());
  }
}
