import 'package:claudewatch/core/modules/module_contracts.dart';
import 'package:claudewatch/core/di/service_locator.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:claudewatch/features/search/domain/repositories/search_repository.dart';
import 'package:claudewatch/features/search/data/repositories/search_repository_impl.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_view_model.dart';

class SearchFeatureModule extends FeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.search',
    name: 'Search Feature',
    version: '1.0.0',
    dependencies: ['core.infrastructure', 'feature.prompts', 'feature.history'],
  );

  @override
  void register(ModuleContext context) {
    // Repositories
    context.locator.registerFactory<SearchRepository>(
      () => SearchRepositoryImpl(
        context.locator.get<PromptRepository>(),
        context.locator.get<HistoryRepository>(),
      ),
    );

    // ViewModels
    context.locator.registerFactory<SearchViewModel>(
      () => SearchViewModel(
        context.locator.get<SearchRepository>(),
        logger: context.locator.get<Logger>(),
      ),
    );
  }
}
