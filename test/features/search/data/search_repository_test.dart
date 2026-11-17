import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/repository/repository_error.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:claudewatch/features/search/data/repositories/search_repository_impl.dart';
import 'package:claudewatch/features/search/domain/models/search_result.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPromptRepository implements PromptRepository {
  @override
  Future<RepositoryResult<List<PromptItem>>> fetchAllPrompts() async =>
      RepositorySuccess([]);

  @override
  Future<RepositoryResult<List<PromptItem>>> fetchFavoritePrompts() async =>
      RepositorySuccess([]);

  @override
  Future<RepositoryResult<PromptItem>> fetchPrompt(String id) async =>
      RepositoryFailure(const RepositoryException(
        type: RepositoryErrorType.notFound,
        message: 'Not found',
      ));

  @override
  Future<RepositoryResult<List<PromptItem>>> searchLocal(String query) async {
    if (query == 'error') {
      return RepositoryFailure(const RepositoryException(
        type: RepositoryErrorType.unexpected,
        message: 'Prompt Error',
      ));
    }
    if (query == 'flutter') {
      return RepositorySuccess([
        PromptItem(
          id: 'p1',
          title: 'Flutter Help',
          contentPreview: 'How to use Flutter',
          provider: 'Claude',
          category: 'Coding',
          createdAt: DateTime(2023, 1, 2),
          updatedAt: DateTime(2023, 1, 2),
        ),
      ]);
    }
    return RepositorySuccess([]);
  }

  @override
  Future<RepositoryResult<PromptItem>> toggleFavorite(String id) async =>
      RepositoryFailure(const RepositoryException(
        type: RepositoryErrorType.notFound,
        message: 'Not found',
      ));
}

class MockHistoryRepository implements HistoryRepository {
  @override
  Future<List<HistoryEntry>> getHistory() async {
    return [
      HistoryEntry(
        id: 'h1',
        provider: 'Claude',
        promptPreview: 'Can you write a Flutter app?',
        tokensUsed: 100,
        timestamp: DateTime(2023, 1, 1),
      ),
      HistoryEntry(
        id: 'h2',
        provider: 'OpenAI',
        promptPreview: 'Write a Python script',
        tokensUsed: 50,
        timestamp: DateTime(2023, 1, 3),
      ),
    ];
  }
}

void main() {
  group('SearchRepositoryImpl Tests', () {
    late SearchRepositoryImpl repository;
    late MockPromptRepository promptRepo;
    late MockHistoryRepository historyRepo;

    setUp(() {
      promptRepo = MockPromptRepository();
      historyRepo = MockHistoryRepository();
      repository = SearchRepositoryImpl(promptRepo, historyRepo);
    });

    test('searchAll aggregates and sorts results descending', () async {
      final result = await repository.searchAll('flutter');

      expect(result, isA<RepositorySuccess>());
      final data = (result as RepositorySuccess).data;
      expect(data.length, 2);

      // Should be sorted descending by time:
      // h2 is not returned because it doesn't match 'flutter'. Wait.
      // Ah, h1 matches 'Flutter'. p1 matches 'Flutter'.
      // p1 time: Jan 2. h1 time: Jan 1.
      // p1 should be first, h1 second.

      expect(data[0].id, 'p1');
      expect(data[0].sourceType, SearchSourceType.prompt);

      expect(data[1].id, 'h1');
      expect(data[1].sourceType, SearchSourceType.history);
    });

    test('searchAll case-insensitive matching in history', () async {
      final result = await repository.searchAll('PYTHON');

      expect(result, isA<RepositorySuccess>());
      final data = (result as RepositorySuccess).data;
      expect(data.length, 1);
      expect(data.first.id, 'h2');
    });

    test('searchAll returns failure if prompt repo fails', () async {
      final result = await repository.searchAll('error');
      expect(result, isA<RepositoryFailure>());
    });
  });
}
