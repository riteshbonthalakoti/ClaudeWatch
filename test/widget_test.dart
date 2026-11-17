import 'package:flutter/material.dart';
import 'package:claudewatch/app/bootstrap/locator_impl.dart';

import 'package:claudewatch/core/config/configuration.dart';
import 'package:claudewatch/core/config/environment.dart';
import 'package:claudewatch/app/config/memory_configuration_provider.dart';
import 'package:claudewatch/shared/config/mock_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claudewatch/main.dart';
import 'package:claudewatch/features/dashboard/presentation/controllers/dashboard_view_model.dart';
import 'package:claudewatch/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:claudewatch/features/history/presentation/controllers/history_view_model.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:claudewatch/features/prompts/presentation/controllers/prompt_library_view_model.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/repository/repository_error.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/features/search/domain/repositories/search_repository.dart';
import 'package:claudewatch/features/search/domain/models/search_result.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_view_model.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<String> getSummary() async => 'Test Summary';
}

class MockHistoryRepository implements HistoryRepository {
  @override
  Future<List<HistoryEntry>> getHistory() async => [
    HistoryEntry(
      id: 'h-001',
      provider: 'Claude',
      promptPreview: 'Test prompt preview',
      tokensUsed: 500,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
}

class MockPromptRepository implements PromptRepository {
  @override
  Future<RepositoryResult<List<PromptItem>>> fetchAllPrompts() async =>
      RepositorySuccess([]);

  @override
  Future<RepositoryResult<List<PromptItem>>> fetchFavoritePrompts() async =>
      RepositorySuccess([]);

  @override
  Future<RepositoryResult<PromptItem>> fetchPrompt(String id) async =>
      RepositoryFailure(
        const RepositoryException(
          type: RepositoryErrorType.notFound,
          message: 'Not found',
        ),
      );

  @override
  Future<RepositoryResult<List<PromptItem>>> searchLocal(String query) async =>
      RepositorySuccess([]);

  @override
  Future<RepositoryResult<PromptItem>> toggleFavorite(String id) async =>
      RepositoryFailure(const RepositoryException(
        type: RepositoryErrorType.notFound,
        message: 'Not implemented',
      ));
}

class MockSearchRepository implements SearchRepository {
  @override
  Future<RepositoryResult<List<SearchResult>>> searchAll(String query) async =>
      RepositorySuccess([]);
}

class MockLogger implements Logger {
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

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final locator = AppServiceLocator.instance;
    locator.reset();

    final env = MockEnvironmentConfiguration(AppEnvironment.development);
    final provider = MemoryConfigurationProvider(environment: env);
    final featureProvider = FeatureFlagProviderImpl(provider);
    final config = AppConfigurationImpl(
      provider: provider,
      featureFlagProvider: featureProvider,
    );

    locator.registerSingleton<AppConfiguration>(config);
    locator.registerFactory<DashboardViewModel>(
      () => DashboardViewModel(MockDashboardRepository(), logger: MockLogger()),
    );
    locator.registerFactory<HistoryViewModel>(
      () => HistoryViewModel(MockHistoryRepository(), logger: MockLogger()),
    );
    locator.registerFactory<PromptLibraryViewModel>(
      () =>
          PromptLibraryViewModel(MockPromptRepository(), logger: MockLogger()),
    );
    locator.registerFactory<SearchViewModel>(
      () => SearchViewModel(MockSearchRepository(), logger: MockLogger()),
    );

    await tester.pumpWidget(ClaudeWatchApp(locator: locator));
    await tester.pumpAndSettle();

    // Verify the bottom navigation bar and the app shell rendered correctly.
    expect(find.byType(NavigationBar), findsOneWidget);
    // Bottom navigation should have 4 items
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });
}
