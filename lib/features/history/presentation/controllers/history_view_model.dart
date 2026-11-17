import 'package:flutter/foundation.dart';
import 'package:claudewatch/app/state/view_model.dart';
import 'package:claudewatch/core/state/state_error.dart';
import 'package:claudewatch/core/state/state_observer.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';

/// ViewModel for the AI Usage History screen.
///
/// Manages transitions through Initial → Loading → Success / Empty / Error.
/// All state updates are immutable via the [ViewModel] base class.
class HistoryViewModel extends ViewModel<List<HistoryEntry>>
    with ChangeNotifier {
  final HistoryRepository _repository;

  HistoryViewModel(
    this._repository, {
    StateObserver? observer,
    required Logger logger,
  }) : super(observer, logger);

  @override
  void onStateUpdated() {
    super.onStateUpdated();
    notifyListeners();
  }

  /// Loads the AI usage history from the repository.
  Future<void> loadHistory() async {
    emitLoading();
    try {
      final entries = await _repository.getHistory();
      if (entries.isEmpty) {
        emitEmpty('No AI interactions yet. Start using Claude widgets!');
      } else {
        emitSuccess(entries);
      }
    } catch (e, stackTrace) {
      emitError(
        StateError(
          type: StateErrorType.unexpected,
          message: 'Failed to load history. Please try again.',
          originalException: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<void> refresh() => loadHistory();
}
