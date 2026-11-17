import 'package:claudewatch/features/history/data/repositories/history_repository_impl.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryRepositoryImpl Tests', () {
    late HistoryRepositoryImpl repository;

    setUp(() {
      repository = HistoryRepositoryImpl();
    });

    test('getHistory returns a non-empty list', () async {
      final entries = await repository.getHistory();
      expect(entries, isNotEmpty);
    });

    test('getHistory returns List<HistoryEntry>', () async {
      final entries = await repository.getHistory();
      expect(entries, isA<List<HistoryEntry>>());
    });

    test('all entries have non-empty id, provider and promptPreview', () async {
      final entries = await repository.getHistory();
      for (final entry in entries) {
        expect(entry.id, isNotEmpty);
        expect(entry.provider, isNotEmpty);
        expect(entry.promptPreview, isNotEmpty);
      }
    });

    test('all entries have positive tokensUsed', () async {
      final entries = await repository.getHistory();
      for (final entry in entries) {
        expect(entry.tokensUsed, greaterThan(0));
      }
    });

    test('entries have unique ids', () async {
      final entries = await repository.getHistory();
      final ids = entries.map((e) => e.id).toSet();
      expect(ids.length, equals(entries.length));
    });

    test('returns an unmodifiable list', () async {
      final entries = await repository.getHistory();
      // List.unmodifiable throws UnsupportedError when mutated; cast to dynamic
      // so the type system doesn't block the call at compile time.
      expect(
        () => (entries as dynamic).add(
          HistoryEntry(
            id: 'fake',
            provider: 'Test',
            promptPreview: 'p',
            tokensUsed: 1,
            timestamp: DateTime.now(),
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
