import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/features/search/domain/models/search_result.dart';

/// Interface for searching across the application's local repositories.
abstract class SearchRepository {
  /// Searches across available local repositories using the given [query].
  /// Results are merged and sorted by timestamp descending.
  Future<RepositoryResult<List<SearchResult>>> searchAll(String query);
}
