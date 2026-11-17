import 'package:claudewatch/features/search/domain/models/search_result.dart';
import 'package:flutter/foundation.dart';

@immutable
class SearchState {
  final List<SearchResult> results;
  final String currentQuery;
  final List<String> recentSearches;

  const SearchState({
    this.results = const [],
    this.currentQuery = '',
    this.recentSearches = const [],
  });

  SearchState copyWith({
    List<SearchResult>? results,
    String? currentQuery,
    List<String>? recentSearches,
  }) {
    return SearchState(
      results: results ?? this.results,
      currentQuery: currentQuery ?? this.currentQuery,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchState &&
        listEquals(other.results, results) &&
        other.currentQuery == currentQuery &&
        listEquals(other.recentSearches, recentSearches);
  }

  @override
  int get hashCode =>
      results.hashCode ^ currentQuery.hashCode ^ recentSearches.hashCode;
}
