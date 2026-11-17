import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';

/// Repository interface for Prompt Library operations.
abstract class PromptRepository {
  /// Fetches all prompts in the library.
  Future<RepositoryResult<List<PromptItem>>> fetchAllPrompts();

  /// Fetches only the favorite prompts.
  Future<RepositoryResult<List<PromptItem>>> fetchFavoritePrompts();

  /// Fetches a specific prompt by its [id].
  Future<RepositoryResult<PromptItem>> fetchPrompt(String id);

  /// Searches the local prompt library for items matching the [query].
  Future<RepositoryResult<List<PromptItem>>> searchLocal(String query);

  /// Toggles the favorite status of the prompt with the given [id].
  Future<RepositoryResult<PromptItem>> toggleFavorite(String id);
}
