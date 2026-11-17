import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/repository/repository_error.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:claudewatch/features/search/domain/models/search_result.dart';
import 'package:claudewatch/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final PromptRepository _promptRepository;
  final HistoryRepository _historyRepository;

  SearchRepositoryImpl(this._promptRepository, this._historyRepository);

  @override
  Future<RepositoryResult<List<SearchResult>>> searchAll(String query) async {
    try {
      final String lowerQuery = query.toLowerCase();

      // Parallel fetch
      final results = await Future.wait([
        _promptRepository.searchLocal(query),
        _historyRepository.getHistory(),
      ]);

      final promptResult = results[0] as RepositoryResult<List<PromptItem>>;
      final historyEntries = results[1] as List<HistoryEntry>;

      final List<SearchResult> combinedResults = [];

      // Process Prompts
      if (promptResult is RepositorySuccess<List<PromptItem>>) {
        for (final prompt in promptResult.data) {
          combinedResults.add(
            SearchResult(
              id: prompt.id,
              title: prompt.title,
              subtitle: prompt.category,
              preview: prompt.contentPreview,
              sourceType: SearchSourceType.prompt,
              provider: prompt.provider,
              createdAt: prompt.createdAt,
            ),
          );
        }
      }

      // Process History (manual filter since getHistory gets all)
      final filteredHistory = historyEntries.where(
        (entry) => entry.promptPreview.toLowerCase().contains(lowerQuery),
      );

      for (final history in filteredHistory) {
        combinedResults.add(
          SearchResult(
            id: history.id,
            title: 'Interaction',
            subtitle: '${history.tokensUsed} tokens',
            preview: history.promptPreview,
            sourceType: SearchSourceType.history,
            provider: history.provider,
            createdAt: history.timestamp,
          ),
        );
      }

      // If prompt lookup failed but history succeeded, maybe we still want to return history?
      // For now, let's just return combined results (though we could surface the failure if needed)
      if (promptResult is RepositoryFailure && combinedResults.isEmpty) {
        return promptResult as RepositoryFailure<List<SearchResult>>;
      }

      // Sort descending by timestamp
      combinedResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return RepositorySuccess(combinedResults);
    } catch (e) {
      return RepositoryFailure(RepositoryException(
        type: RepositoryErrorType.unexpected,
        message: 'Search failed: $e',
        originalException: e,
      ));
    }
  }
}
