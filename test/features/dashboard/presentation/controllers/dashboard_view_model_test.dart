import 'package:flutter_test/flutter_test.dart';
import 'package:claudewatch/features/dashboard/presentation/controllers/dashboard_view_model.dart';
import 'package:claudewatch/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';

class MockDashboardRepository implements DashboardRepository {
  String response = 'Test Summary';
  bool throwError = false;

  @override
  Future<String> getSummary() async {
    if (throwError) throw Exception('Network error');
    return response;
  }
}

class MockLogger implements Logger {
  @override
  void log({
    required LogLevel level,
    required LogCategory category,
    required String message,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void trace(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  }) {}
  @override
  void debug(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void info(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  }) {}
  @override
  void warning(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void error(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void critical(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
}

void main() {
  group('DashboardViewModel Tests', () {
    late DashboardViewModel viewModel;
    late MockDashboardRepository mockRepository;
    late MockLogger mockLogger;

    setUp(() {
      mockRepository = MockDashboardRepository();
      mockLogger = MockLogger();
      viewModel = DashboardViewModel(mockRepository, logger: mockLogger);
    });

    test('initial state is InitialState', () {
      expect(viewModel.state, isA<InitialState>());
    });

    test(
      'loadDashboard emits SuccessState with data when successful',
      () async {
        final future = viewModel.loadDashboard();
        expect(viewModel.state, isA<LoadingState>());
        await future;
        expect(viewModel.state, isA<SuccessState<String>>());
        expect((viewModel.state as SuccessState<String>).data, 'Test Summary');
      },
    );

    test('loadDashboard emits EmptyState when data is empty', () async {
      mockRepository.response = '';
      await viewModel.loadDashboard();
      expect(viewModel.state, isA<EmptyState>());
    });

    test('loadDashboard emits ErrorState on exception', () async {
      mockRepository.throwError = true;
      await viewModel.loadDashboard();
      expect(viewModel.state, isA<ErrorState>());
    });
  });
}
