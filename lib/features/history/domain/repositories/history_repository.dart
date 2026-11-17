import 'package:claudewatch/core/repository/base_repository.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';

/// Abstract contract for the AI usage history repository.
abstract class HistoryRepository extends BaseRepository {
  /// Returns the list of past AI interactions, ordered by most recent first.
  Future<List<HistoryEntry>> getHistory();
}
