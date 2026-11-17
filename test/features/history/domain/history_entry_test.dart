import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryEntry Model Tests', () {
    final now = DateTime(2026, 7, 25, 10, 0);

    final entry = HistoryEntry(
      id: 'h-001',
      provider: 'Claude',
      promptPreview: 'Explain isolates in Dart.',
      tokensUsed: 1200,
      timestamp: now,
    );

    test('equality is based on id only', () {
      final duplicate = HistoryEntry(
        id: 'h-001',
        provider: 'Different Provider',
        promptPreview: 'Different prompt',
        tokensUsed: 9999,
        timestamp: now.add(const Duration(days: 1)),
      );
      expect(entry, equals(duplicate));
    });

    test('different ids are not equal', () {
      final other = HistoryEntry(
        id: 'h-002',
        provider: 'Claude',
        promptPreview: 'Explain isolates in Dart.',
        tokensUsed: 1200,
        timestamp: now,
      );
      expect(entry, isNot(equals(other)));
    });

    test('hashCode is based on id', () {
      expect(entry.hashCode, equals('h-001'.hashCode));
    });

    test('toString includes id, provider, and token count', () {
      final str = entry.toString();
      expect(str, contains('h-001'));
      expect(str, contains('Claude'));
      expect(str, contains('1200'));
    });

    test('fields are correctly set', () {
      expect(entry.id, 'h-001');
      expect(entry.provider, 'Claude');
      expect(entry.promptPreview, 'Explain isolates in Dart.');
      expect(entry.tokensUsed, 1200);
      expect(entry.timestamp, now);
    });
  });
}
