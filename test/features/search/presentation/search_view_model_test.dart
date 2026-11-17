import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/repository/repository_error.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/search/domain/models/search_result.dart';
import 'package:claudewatch/features/search/domain/repositories/search_repository.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_view_model.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLogger implements Logger {
  @override
  void debug(String message, {LogCategory category = LogCategory.general, LogContext? context, Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {LogCategory category = LogCategory.general, LogContext? context, Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String message, {LogCategory category = LogCategory.general, LogContext? context}) {}
  @override
  void warning(String message, {LogCategory category = LogCategory.general, LogContext? context, Object? error, StackTrace? stackTrace}) {}
  @override
  void critical(String message, {LogCategory category = LogCategory.general, LogContext? context, Object? error, StackTrace? stackTrace}) {}
  @override
  void trace(String message, {LogCategory category = LogCategory.general, LogContext? context}) {}
  @override
  void log({required LogLevel level, required LogCategory category, required String message, LogContext? context, Object? error, StackTrace? stackTrace}) {}
}

class MockSearchRepository implements SearchRepository {
  @override
  Future<RepositoryResult<List<SearchResult>>> searchAll(String query) async {
    if (query == 'error') {
      return RepositoryFailure(const RepositoryException(
        type: RepositoryErrorType.unexpected,
        message: 'Search error',
      ));
    }
    if (query == 'empty') return RepositorySuccess([]);

    return RepositorySuccess([
      SearchResult(
        id: '1',
        title: query,
        subtitle: 'sub',
        preview: 'prev',
        sourceType: SearchSourceType.prompt,
        provider: 'Claude',
        createdAt: DateTime(2023, 1, 1),
      ),
    ]);
  }
}

void main() {
  group('SearchViewModel Tests', () {
    late SearchViewModel viewModel;
    late MockSearchRepository repository;

    setUp(() {
      repository = MockSearchRepository();
      viewModel = SearchViewModel(repository, logger: MockLogger());
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('Initial state is InitialState', () {
      expect(viewModel.state, isA<InitialState<SearchState>>());
    });

    test('load() emits InitialState', () {
      viewModel.load();
      expect(viewModel.state, isA<InitialState<SearchState>>());
    });

    test('search() debounces and emits Loading then Success', () async {
      viewModel.search('test');

      // Since there is a 300ms debounce, state is still Initial
      expect(viewModel.state, isA<InitialState<SearchState>>());

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 350));

      // Should have transitioned to loading then success, wait for microtasks
      await Future.delayed(Duration.zero);

      expect(viewModel.state, isA<SuccessState<SearchState>>());
      final data = viewModel.searchState;
      expect(data.currentQuery, 'test');
      expect(data.results.length, 1);
      expect(data.recentSearches, contains('test'));
    });

    test('search() with empty query goes to InitialState', () async {
      final stateData = viewModel.searchState;
      // First populate some recents directly or via a search

      viewModel.search('');
      expect(viewModel.state, isA<InitialState<SearchState>>());
    });

    test('search() emits EmptyState for no results', () async {
      viewModel.search('empty');
      await Future.delayed(const Duration(milliseconds: 350));
      await Future.delayed(Duration.zero);

      expect(viewModel.state, isA<EmptyState<SearchState>>());
    });

    test('search() emits ErrorState on failure', () async {
      viewModel.search('error');
      await Future.delayed(const Duration(milliseconds: 350));
      await Future.delayed(Duration.zero);

      expect(viewModel.state, isA<ErrorState<SearchState>>());
    });

    test(
      'clear() resets state to InitialState with empty query and results',
      () async {
        viewModel.search('test');
        await Future.delayed(const Duration(milliseconds: 350));

        viewModel.clear();
      expect(viewModel.state, isA<InitialState<SearchState>>());
      final data = viewModel.searchState;
      expect(data.currentQuery, '');
        expect(data.results, isEmpty);
      },
    );
  });
}
