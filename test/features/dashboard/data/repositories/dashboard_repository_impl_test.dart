import 'package:flutter_test/flutter_test.dart';
import 'package:claudewatch/features/dashboard/data/repositories/dashboard_repository_impl.dart';

void main() {
  group('DashboardRepositoryImpl Tests', () {
    late DashboardRepositoryImpl repository;

    setUp(() {
      repository = DashboardRepositoryImpl();
    });

    test('getSummary returns realistic data', () async {
      final summary = await repository.getSummary();
      expect(summary, contains('AI Usage Summary'));
      expect(summary, contains('120 Tokens'));
    });
  });
}
