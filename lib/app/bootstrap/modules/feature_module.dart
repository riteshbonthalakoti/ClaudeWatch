import 'package:claudewatch/core/modules/module_contracts.dart';
import 'package:claudewatch/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:claudewatch/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:claudewatch/features/dashboard/presentation/controllers/dashboard_view_model.dart';
import 'package:claudewatch/features/history/data/repositories/history_repository_impl.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';
import 'package:claudewatch/features/history/presentation/controllers/history_view_model.dart';
import 'package:claudewatch/features/prompts/data/repositories/prompt_repository_impl.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:claudewatch/features/prompts/presentation/controllers/prompt_library_view_model.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/state/state_observer.dart';

class DashboardFeatureModule extends FeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.dashboard',
    name: 'Dashboard',
    version: '1.0.0',
    dependencies: ['core.infrastructure.services'],
  );

  @override
  void register(ModuleContext context) {
    final locator = context.locator;
    // Register Feature Repositories (Lazy Singleton)
    locator.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(),
    );

    // Register Presentation ViewModels (Factory - fresh instance every request)
    locator.registerFactory<DashboardViewModel>(
      () => DashboardViewModel(
        locator.get<DashboardRepository>(),
        observer: locator.isRegistered<StateObserver>()
            ? locator.get<StateObserver>()
            : null,
        logger: locator.get<Logger>(),
      ),
    );
  }
}

class HistoryFeatureModule extends FeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.history',
    name: 'History',
    version: '1.0.0',
    dependencies: ['core.infrastructure.services'],
  );

  @override
  void register(ModuleContext context) {
    final locator = context.locator;

    // Register History Repository (Lazy Singleton)
    locator.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(),
    );

    // Register History ViewModel (Factory - fresh instance every request)
    locator.registerFactory<HistoryViewModel>(
      () => HistoryViewModel(
        locator.get<HistoryRepository>(),
        observer: locator.isRegistered<StateObserver>()
            ? locator.get<StateObserver>()
            : null,
        logger: locator.get<Logger>(),
      ),
    );
  }
}

class PromptLibraryFeatureModule extends FeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.prompts',
    name: 'Prompts',
    version: '1.0.0',
    dependencies: ['core.infrastructure.services'],
  );

  @override
  void register(ModuleContext context) {
    final locator = context.locator;

    // Register Prompt Repository (Lazy Singleton)
    locator.registerLazySingleton<PromptRepository>(
      () => PromptRepositoryImpl(),
    );

    // Register Prompt ViewModel (Factory)
    locator.registerFactory<PromptLibraryViewModel>(
      () => PromptLibraryViewModel(
        locator.get<PromptRepository>(),
        observer: locator.isRegistered<StateObserver>()
            ? locator.get<StateObserver>()
            : null,
        logger: locator.get<Logger>(),
      ),
    );
  }
}
