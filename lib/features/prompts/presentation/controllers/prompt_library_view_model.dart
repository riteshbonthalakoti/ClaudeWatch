import 'package:claudewatch/app/state/view_model.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/state/state_error.dart';
import 'package:claudewatch/core/state/state_observer.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:flutter/foundation.dart';

@immutable
class PromptLibraryState {
  final List<PromptItem> prompts;
  final List<PromptItem> filteredPrompts;
  final String searchQuery;
  final String selectedCategory;

  const PromptLibraryState({
    this.prompts = const [],
    this.filteredPrompts = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  PromptLibraryState copyWith({
    List<PromptItem>? prompts,
    List<PromptItem>? filteredPrompts,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return PromptLibraryState(
      prompts: prompts ?? this.prompts,
      filteredPrompts: filteredPrompts ?? this.filteredPrompts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class PromptLibraryViewModel extends ViewModel<PromptLibraryState>
    with ChangeNotifier {
  final PromptRepository _repository;
  final Logger? _logger;

  PromptLibraryViewModel(
    this._repository, {
    StateObserver? observer,
    Logger? logger,
  }) : _logger = logger,
       super(observer, logger ?? _MockLogger());

  @override
  void onStateUpdated() {
    super.onStateUpdated();
    notifyListeners();
  }

  PromptLibraryState get currentData {
    if (state is SuccessState<PromptLibraryState>) {
      return (state as SuccessState<PromptLibraryState>).data;
    } else if (state is LoadingState<PromptLibraryState>) {
      return (state as LoadingState<PromptLibraryState>).previousData ??
          const PromptLibraryState();
    } else if (state is ErrorState<PromptLibraryState>) {
      return (state as ErrorState<PromptLibraryState>).previousData ??
          const PromptLibraryState();
    }
    return const PromptLibraryState();
  }

  Future<void> load() async {
    if (state is LoadingState) return;

    emitLoading();

    final result = await _repository.fetchAllPrompts();

    if (result is RepositorySuccess<List<PromptItem>>) {
      final prompts = result.data;
      if (prompts.isEmpty) {
        emitEmpty('No prompts available yet.');
      } else {
        final newState = currentData.copyWith(
          prompts: prompts,
          filteredPrompts: _applyFilters(
            prompts: prompts,
            query: currentData.searchQuery,
            category: currentData.selectedCategory,
          ),
        );
        emitSuccess(newState);
      }
    } else if (result is RepositoryFailure<List<PromptItem>>) {
      emitError(
        StateError(
          type: StateErrorType.unexpected,
          message: 'Failed to load prompts.',
          originalException: result.error,
        ),
      );
    }
  }

  Future<void> search(String query) async {
    if (state is! SuccessState<PromptLibraryState> &&
        state is! EmptyState<PromptLibraryState>) {
      await load();
    }

    final newState = currentData.copyWith(
      searchQuery: query,
      filteredPrompts: _applyFilters(
        prompts: currentData.prompts,
        query: query,
        category: currentData.selectedCategory,
      ),
    );

    if (newState.filteredPrompts.isEmpty) {
      emitEmpty('No prompts found for "$query".');
    } else {
      emitSuccess(newState);
    }
  }

  void filterByCategory(String category) {
    final newState = currentData.copyWith(
      selectedCategory: category,
      filteredPrompts: _applyFilters(
        prompts: currentData.prompts,
        query: currentData.searchQuery,
        category: category,
      ),
    );

    if (newState.filteredPrompts.isEmpty) {
      emitEmpty('No prompts found in this category.');
    } else {
      emitSuccess(newState);
    }
  }

  Future<void> toggleFavorite(String id) async {
    final result = await _repository.toggleFavorite(id);

    if (result is RepositorySuccess<PromptItem>) {
      final updatedPrompt = result.data;
      final updatedPrompts = currentData.prompts.map((p) {
        return p.id == id ? updatedPrompt : p;
      }).toList();

      final newState = currentData.copyWith(
        prompts: updatedPrompts,
        filteredPrompts: _applyFilters(
          prompts: updatedPrompts,
          query: currentData.searchQuery,
          category: currentData.selectedCategory,
        ),
      );

      if (newState.filteredPrompts.isEmpty &&
          currentData.selectedCategory == 'Favorites') {
        emitEmpty('No favorite prompts yet.');
      } else {
        emitSuccess(newState);
      }
    } else if (result is RepositoryFailure<PromptItem>) {
      _logger?.error('Failed to toggle favorite for $id: ${result.error}');
    }
  }

  @override
  Future<void> refresh() async {
    emitLoading();
    await load();
  }

  List<PromptItem> _applyFilters({
    required List<PromptItem> prompts,
    required String query,
    required String category,
  }) {
    final normalizedQuery = query.toLowerCase();

    return prompts.where((p) {
      if (category == 'Favorites' && !p.favorite) return false;
      if (category != 'All' &&
          category != 'Favorites' &&
          p.category != category)
        return false;

      if (normalizedQuery.isNotEmpty) {
        final matchesTitle = p.title.toLowerCase().contains(normalizedQuery);
        final matchesPreview = p.contentPreview.toLowerCase().contains(
          normalizedQuery,
        );
        final matchesCategory = p.category.toLowerCase().contains(
          normalizedQuery,
        );
        final matchesTags = p.tags.any(
          (t) => t.toLowerCase().contains(normalizedQuery),
        );
        if (!matchesTitle &&
            !matchesPreview &&
            !matchesCategory &&
            !matchesTags) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

class _MockLogger implements Logger {
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
