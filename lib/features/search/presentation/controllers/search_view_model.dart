import 'dart:async';
import 'package:claudewatch/app/state/view_model.dart';
import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/core/state/state_error.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/features/search/domain/models/search_result.dart';
import 'package:claudewatch/features/search/domain/repositories/search_repository.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_state.dart';
import 'package:flutter/foundation.dart';

class SearchViewModel extends ViewModel<SearchState> with ChangeNotifier {
  final SearchRepository _repository;
  Timer? _debounceTimer;
  SearchState _searchState = const SearchState();

  SearchState get searchState => _searchState;

  SearchViewModel(
    this._repository, {
    required Logger logger,
  }) : super(null, logger);

  @override
  void onStateUpdated() {
    super.onStateUpdated();
    notifyListeners();
  }

  void load() {
    emit(const InitialState());
  }

  void search(String query) {
    // If query is empty, cancel timer and go to initial state with recent searches
    if (query.trim().isEmpty) {
      _debounceTimer?.cancel();
      clear();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _searchState = _searchState.copyWith(currentQuery: query);
    emitLoading();

    final result = await _repository.searchAll(query);

    if (isDisposed) return;

    if (result is RepositorySuccess<List<SearchResult>>) {
      final results = result.data;
      
      // Add to recent searches if new
      final updatedRecents = List<String>.from(_searchState.recentSearches);
      if (!updatedRecents.contains(query)) {
        updatedRecents.insert(0, query);
        if (updatedRecents.length > 5) {
          updatedRecents.removeLast();
        }
      }

      _searchState = _searchState.copyWith(
        results: results,
        currentQuery: query,
        recentSearches: updatedRecents,
      );

      if (results.isEmpty) {
        emitEmpty('No results found for "$query"');
      } else {
        emitSuccess(_searchState);
      }
    } else if (result is RepositoryFailure<List<SearchResult>>) {
      emitError(StateError(
        type: StateErrorType.unexpected,
        message: result.error.toString(),
      ));
    }
  }

  void clear() {
    _searchState = _searchState.copyWith(
      currentQuery: '',
      results: [],
    );
    emit(const InitialState());
  }

  void refresh() {
    if (_searchState.currentQuery.isNotEmpty) {
      _performSearch(_searchState.currentQuery);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
