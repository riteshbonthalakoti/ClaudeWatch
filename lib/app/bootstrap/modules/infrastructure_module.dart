import 'package:claudewatch/core/modules/module_contracts.dart';
import 'package:claudewatch/app/bootstrap/modules/placeholder_services.dart';
import 'package:claudewatch/core/analytics/analytics_tracker.dart';
import 'package:claudewatch/core/background/background_task_manager.dart';
import 'package:claudewatch/core/navigation/app_router.dart';
import 'package:claudewatch/core/notifications/notification_service.dart';
import 'package:claudewatch/core/persistence/local_storage.dart';
import 'package:claudewatch/core/sync/sync_manager.dart';
import 'package:claudewatch/shared/repository/placeholders/configuration_repository.dart';
import 'package:claudewatch/shared/repository/placeholders/settings_repository.dart';
import 'package:claudewatch/shared/repository/placeholders/device_repository.dart';
import 'package:claudewatch/shared/repository/placeholders/capture_repository.dart';
import 'package:claudewatch/shared/repository/placeholders/analytics_repository.dart'
    as repo_analytics;
import 'package:claudewatch/shared/repository/placeholders/prediction_repository.dart';

class InfrastructureModule extends ApplicationModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'core.infrastructure.services',
    name: 'Infrastructure Services',
    version: '1.0.0',
    dependencies: ['core.infrastructure'],
  );

  @override
  void register(ModuleContext context) {
    final locator = context.locator;
    locator.registerLazySingleton<AppRouter>(() => PlaceholderRouter());
    locator.registerLazySingleton<LocalStorage>(
      () => PlaceholderLocalStorage(),
    );
    locator.registerLazySingleton<AnalyticsTracker>(
      () => PlaceholderAnalytics(),
    );
    locator.registerLazySingleton<NotificationService>(
      () => PlaceholderNotificationService(),
    );
    locator.registerLazySingleton<BackgroundTaskManager>(
      () => PlaceholderBackgroundTaskManager(),
    );
    locator.registerLazySingleton<SyncManager>(() => PlaceholderSyncManager());

    // Placeholder Repositories
    locator.registerLazySingleton<ConfigurationRepository>(
      () => ConfigurationRepository(),
    );
    locator.registerLazySingleton<SettingsRepository>(
      () => SettingsRepository(),
    );
    locator.registerLazySingleton<DeviceRepository>(() => DeviceRepository());
    locator.registerLazySingleton<CaptureRepository>(() => CaptureRepository());
    locator.registerLazySingleton<repo_analytics.AnalyticsRepository>(
      () => repo_analytics.AnalyticsRepository(),
    );
    locator.registerLazySingleton<PredictionRepository>(
      () => PredictionRepository(),
    );
  }
}
