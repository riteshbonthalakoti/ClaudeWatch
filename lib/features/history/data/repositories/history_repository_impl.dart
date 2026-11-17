import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';

/// Local placeholder implementation of [HistoryRepository].
///
/// Returns a fixed set of realistic AI interaction records.
/// Replace with a real data source (local DB, API) in a future work package.
class HistoryRepositoryImpl implements HistoryRepository {
  static final List<HistoryEntry> _placeholder = [
    HistoryEntry(
      id: 'h-001',
      provider: 'Claude',
      promptPreview:
          'Explain the difference between isolates and async/await in Dart, '
          'and when should I prefer one over the other for CPU-intensive tasks?',
      tokensUsed: 1240,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    HistoryEntry(
      id: 'h-002',
      provider: 'Claude',
      promptPreview:
          'Write a Flutter widget that displays a live battery percentage '
          'using a stream from the platform channel.',
      tokensUsed: 890,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HistoryEntry(
      id: 'h-003',
      provider: 'Claude',
      promptPreview:
          'Summarise the key changes in the Flutter 3.22 release notes '
          'and flag anything that might break existing Material 3 code.',
      tokensUsed: 2150,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    HistoryEntry(
      id: 'h-004',
      provider: 'Claude',
      promptPreview:
          'Generate a Dart data class with JSON serialisation for a REST API '
          'response that contains nested pagination metadata.',
      tokensUsed: 560,
      timestamp: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    HistoryEntry(
      id: 'h-005',
      provider: 'Claude',
      promptPreview:
          'Review my dependency injection bootstrap code and identify any '
          'potential circular dependency risks or missing registrations.',
      tokensUsed: 3100,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HistoryEntry(
      id: 'h-006',
      provider: 'Claude',
      promptPreview:
          'Help me write a Maestro YAML test flow that navigates through all '
          'bottom nav tabs and asserts each screen title.',
      tokensUsed: 720,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    HistoryEntry(
      id: 'h-007',
      provider: 'Claude',
      promptPreview:
          'What is the recommended approach for handling deep links in a '
          'GoRouter-based Flutter application with auth guards?',
      tokensUsed: 1680,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<HistoryEntry>> getHistory() async {
    // Simulate a short network / DB fetch delay.
    await Future.delayed(const Duration(milliseconds: 800));
    return List.unmodifiable(_placeholder);
  }
}
