import 'package:claudewatch/core/repository/base_repository.dart';

abstract class DashboardRepository extends BaseRepository {
  Future<String> getSummary();
}
