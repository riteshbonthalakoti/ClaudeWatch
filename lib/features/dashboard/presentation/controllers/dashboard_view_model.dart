import 'package:flutter/foundation.dart';
import 'package:claudewatch/app/state/view_model.dart';
import 'package:claudewatch/core/state/state_error.dart';
import 'package:claudewatch/core/state/state_observer.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardViewModel extends ViewModel<String> with ChangeNotifier {
  final DashboardRepository _repository;

  DashboardViewModel(
    this._repository, {
    StateObserver? observer,
    required Logger logger,
  }) : super(observer, logger);

  @override
  void onStateUpdated() {
    super.onStateUpdated();
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    emitLoading();
    try {
      final summary = await _repository.getSummary();
      if (summary.isEmpty) {
        emitEmpty('No summary data available.');
      } else {
        emitSuccess(summary);
      }
    } catch (e) {
      emitError(
        StateError(
          type: StateErrorType.unexpected,
          message: 'Failed to load dashboard: $e',
          originalException: e,
        ),
      );
    }
  }
}
