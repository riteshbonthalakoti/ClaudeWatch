import 'dart:math';
import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/repository/repository_error.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';

/// Implementation of [PromptRepository] using static placeholder data.
class PromptRepositoryImpl implements PromptRepository {
  final List<PromptItem> _items = _generatePlaceholderPrompts();

  // Simulated network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(500)));
  }

  @override
  Future<RepositoryResult<List<PromptItem>>> fetchAllPrompts() async {
    try {
      await _simulateDelay();
      return RepositorySuccess(List.unmodifiable(_items));
    } catch (e) {
      return RepositoryFailure(
        RepositoryException(
          type: RepositoryErrorType.unexpected,
          message: 'Failed to fetch prompts: $e',
        ),
      );
    }
  }

  @override
  Future<RepositoryResult<List<PromptItem>>> fetchFavoritePrompts() async {
    try {
      await _simulateDelay();
      final favorites = _items.where((p) => p.favorite).toList();
      return RepositorySuccess(List.unmodifiable(favorites));
    } catch (e) {
      return RepositoryFailure(
        RepositoryException(
          type: RepositoryErrorType.unexpected,
          message: 'Failed to fetch favorite prompts: $e',
        ),
      );
    }
  }

  @override
  Future<RepositoryResult<PromptItem>> fetchPrompt(String id) async {
    try {
      await _simulateDelay();
      final prompt = _items.firstWhere(
        (p) => p.id == id,
        orElse: () => throw const RepositoryException(
          type: RepositoryErrorType.notFound,
          message: 'Prompt not found',
        ),
      );
      return RepositorySuccess(prompt);
    } catch (e) {
      if (e is RepositoryException) return RepositoryFailure(e);
      return RepositoryFailure(
        RepositoryException(
          type: RepositoryErrorType.unexpected,
          message: 'Failed to fetch prompt: $e',
        ),
      );
    }
  }

  @override
  Future<RepositoryResult<List<PromptItem>>> searchLocal(String query) async {
    try {
      await _simulateDelay();
      if (query.trim().isEmpty) {
        return RepositorySuccess(List.unmodifiable(_items));
      }

      final normalizedQuery = query.toLowerCase();
      final results = _items.where((p) {
        return p.title.toLowerCase().contains(normalizedQuery) ||
            p.contentPreview.toLowerCase().contains(normalizedQuery) ||
            p.category.toLowerCase().contains(normalizedQuery) ||
            p.tags.any((t) => t.toLowerCase().contains(normalizedQuery));
      }).toList();

      return RepositorySuccess(List.unmodifiable(results));
    } catch (e) {
      return RepositoryFailure(
        RepositoryException(
          type: RepositoryErrorType.unexpected,
          message: 'Search failed: $e',
        ),
      );
    }
  }

  @override
  Future<RepositoryResult<PromptItem>> toggleFavorite(String id) async {
    try {
      await _simulateDelay();
      final index = _items.indexWhere((p) => p.id == id);
      if (index == -1) {
        throw const RepositoryException(
          type: RepositoryErrorType.notFound,
          message: 'Prompt not found',
        );
      }

      final current = _items[index];
      final updated = current.copyWith(
        favorite: !current.favorite,
        updatedAt: DateTime.now(),
      );

      _items[index] = updated;
      return RepositorySuccess(updated);
    } catch (e) {
      if (e is RepositoryException) return RepositoryFailure(e);
      return RepositoryFailure(
        RepositoryException(
          type: RepositoryErrorType.unexpected,
          message: 'Failed to toggle favorite: $e',
        ),
      );
    }
  }

  static List<PromptItem> _generatePlaceholderPrompts() {
    final now = DateTime.now();
    return [
      PromptItem(
        id: 'prompt_1',
        title: 'Flutter Widget Generator',
        contentPreview: 'Create a fully styled Flutter widget that...',
        provider: 'Claude',
        category: 'Coding',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        favorite: true,
        tags: ['flutter', 'ui', 'dart'],
        estimatedTokens: 150,
      ),
      PromptItem(
        id: 'prompt_2',
        title: 'Code Review Assistant',
        contentPreview: 'Review this Dart code for performance and...',
        provider: 'Claude',
        category: 'Coding',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        favorite: false,
        tags: ['review', 'dart', 'performance'],
        estimatedTokens: 80,
      ),
      PromptItem(
        id: 'prompt_3',
        title: 'Blog Post Outline',
        contentPreview:
            'Write a comprehensive outline for a blog post about...',
        provider: 'Claude',
        category: 'Writing',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
        favorite: true,
        tags: ['blog', 'writing'],
        estimatedTokens: 120,
      ),
      PromptItem(
        id: 'prompt_4',
        title: 'Data Analysis Script',
        contentPreview: 'Write a python script using pandas to analyze...',
        provider: 'Claude',
        category: 'Coding',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 11)),
        favorite: false,
        tags: ['python', 'data', 'pandas'],
        estimatedTokens: 250,
      ),
      PromptItem(
        id: 'prompt_5',
        title: 'Market Research Summary',
        contentPreview:
            'Summarize the latest market trends for wearable tech...',
        provider: 'Claude',
        category: 'Research',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
        favorite: false,
        tags: ['research', 'tech'],
        estimatedTokens: 300,
      ),
    ];
  }
}
