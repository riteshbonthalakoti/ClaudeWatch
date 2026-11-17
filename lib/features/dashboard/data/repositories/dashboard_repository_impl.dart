import 'package:claudewatch/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<String> getSummary() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    return 'AI Usage Summary:\n- 120 Tokens Used Today\n- 3 Active Prompts\n- Model: Claude 3.5 Sonnet\n- System Status: Optimal';
  }
}
