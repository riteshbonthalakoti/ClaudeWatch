import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/search/domain/models/search_result.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_state.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_view_model.dart';
import 'package:claudewatch/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/features/search/domain/repositories/search_repository.dart';
import 'package:claudewatch/core/repository/repository_result.dart';

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
  Future<RepositoryResult<List<SearchResult>>> searchAll(String query) async => RepositorySuccess([]);
}

class MockSearchViewModel extends SearchViewModel {
  MockSearchViewModel() : super(MockSearchRepository(), logger: MockLogger());

  ViewState<SearchState> _mockState = const InitialState();
  SearchState _mockSearchState = const SearchState();

  @override
  ViewState<SearchState> get state => _mockState;

  @override
  SearchState get searchState => _mockSearchState;

  void setState(ViewState<SearchState> newState, {SearchState? searchStateData}) {
    _mockState = newState;
    if (searchStateData != null) {
      _mockSearchState = searchStateData;
    }
    notifyListeners();
  }
}

void main() {
  group('SearchScreen Tests', () {
    late MockSearchViewModel viewModel;

    setUp(() {
      viewModel = MockSearchViewModel();
    });

    Widget buildScreen() {
      return MaterialApp(home: SearchScreen(viewModel: viewModel));
    }

    testWidgets('shows recent searches on initial state', (tester) async {
      viewModel.setState(
        const InitialState(),
        searchStateData: const SearchState(recentSearches: ['Flutter', 'Dart']),
      );

      await tester.pumpWidget(buildScreen());

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('shows loading indicator on loading state', (tester) async {
      viewModel.setState(const LoadingState());

      await tester.pumpWidget(buildScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows search results on success state', (tester) async {
      viewModel.setState(
        const SuccessState(SearchState()), // doesn't actually use state.data in view
        searchStateData: SearchState(
          results: [
            SearchResult(
              id: '1',
              title: 'Test Prompt',
              subtitle: 'Coding',
              preview: 'Write a flutter app',
              sourceType: SearchSourceType.prompt,
              provider: 'Claude',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );

      await tester.pumpWidget(buildScreen());

      expect(find.text('Test Prompt'), findsOneWidget);
      expect(find.text('Write a flutter app'), findsOneWidget);
    });

    testWidgets('shows empty state message', (tester) async {
      viewModel.setState(const EmptyState(message: 'No results found'));

      await tester.pumpWidget(buildScreen());

      expect(find.text('No results found'), findsOneWidget);
    });
  });
}
