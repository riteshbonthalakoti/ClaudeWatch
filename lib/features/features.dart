import 'package:claudewatch/core/state/state_notifier.dart';
import 'package:claudewatch/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardController extends AppStateNotifier<String> {
  final DashboardRepository _repository;

  DashboardController(this._repository) : super('Initial State');

  Future<void> loadDashboard() async {
    final summary = await _repository.getSummary();
    updateState(summary);
  }
}
