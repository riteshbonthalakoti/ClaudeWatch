import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/features/prompts/data/repositories/prompt_repository_impl.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromptRepositoryImpl Tests', () {
    late PromptRepositoryImpl repository;

    setUp(() {
      repository = PromptRepositoryImpl();
    });

    test('fetchAllPrompts returns list of prompts', () async {
      final result = await repository.fetchAllPrompts();
      expect(result, isA<RepositorySuccess>());
      expect((result as RepositorySuccess).data.isNotEmpty, true);
    });

    test('fetchFavoritePrompts returns only favorites', () async {
      final result = await repository.fetchFavoritePrompts();
      expect(result, isA<RepositorySuccess>());
      final favorites = (result as RepositorySuccess).data;
      expect(favorites.every((p) => (p as PromptItem).favorite), true);
    });

    test('fetchPrompt returns a prompt by id', () async {
      final all = await repository.fetchAllPrompts();
      final firstId = (all as RepositorySuccess).data.first.id;

      final result = await repository.fetchPrompt(firstId);
      expect(result, isA<RepositorySuccess>());
      expect((result as RepositorySuccess).data.id, firstId);
    });

    test('searchLocal filters by title', () async {
      final result = await repository.searchLocal('Flutter');
      expect(result, isA<RepositorySuccess>());
      final data = (result as RepositorySuccess).data;
      expect(data.isNotEmpty, true);
      expect(
        data.any((p) => (p as PromptItem).title.contains('Flutter')),
        true,
      );
    });

    test('toggleFavorite changes the favorite status', () async {
      final all = await repository.fetchAllPrompts();
      final first = (all as RepositorySuccess).data.first;
      final initialFavorite = first.favorite;

      final result = await repository.toggleFavorite(first.id);
      expect(result, isA<RepositorySuccess>());
      expect((result as RepositorySuccess).data.favorite, !initialFavorite);
    });
  });
}
