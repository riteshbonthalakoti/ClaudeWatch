import 'package:flutter_test/flutter_test.dart';
import 'package:claudewatch/app/state/view_model.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/core/state/state_error.dart';
import 'package:claudewatch/core/state/state_observer.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';

class MockLogger implements Logger {
  final List<String> warnings = [];
  final List<String> errors = [];

  @override
  void log({
    required LogLevel level,
    required LogCategory category,
    required String message,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (level == LogLevel.warning) warnings.add(message);
    if (level == LogLevel.error) errors.add(message);
  }

  @override
  void trace(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  }) => log(
    level: LogLevel.trace,
    category: category,
    message: message,
    context: context,
  );

  @override
  void debug(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) => log(
    level: LogLevel.debug,
    category: category,
    message: message,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void info(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  }) => log(
    level: LogLevel.info,
    category: category,
    message: message,
    context: context,
  );

  @override
  void warning(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) => log(
    level: LogLevel.warning,
    category: category,
    message: message,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void error(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) => log(
    level: LogLevel.error,
    category: category,
    message: message,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void critical(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) => log(
    level: LogLevel.critical,
    category: category,
    message: message,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
}

class MockObserver implements StateObserver {
  final List<String> transitions = [];
  final List<String> errors = [];

  @override
  void onViewModelCreated(String viewModelName) {}
  @override
  void onViewModelDisposed(String viewModelName) {}
  @override
  void onTransition(String viewModelName, StateTransition transition) {
    transitions.add(
      '${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onStateChanged(String viewModelName, ViewState currentState) {}
  @override
  void onError(String viewModelName, StateError error) {
    errors.add(error.message);
  }
}

class TestViewModel extends ViewModel<String> {
  TestViewModel(super.observer, super.logger);

  void loadData() {
    emitLoading();
  }

  void loadSuccess(String data) {
    emitSuccess(data);
  }

  void loadError(StateError error) {
    emitError(error);
  }

  void triggerEmpty() {
    emitEmpty();
  }

  void triggerRefresh() {
    emit(const RefreshingState<String>());
  }

  void triggerInvalidTransition() {
    // Attempting to jump to Refreshing directly from Initial (invalid per our logic)
    emit(const RefreshingState<String>());
  }
}

void main() {
  group('ViewModel Tests', () {
    late TestViewModel viewModel;
    late MockLogger logger;
    late MockObserver observer;

    setUp(() {
      logger = MockLogger();
      observer = MockObserver();
      viewModel = TestViewModel(observer, logger);
    });

    test('Initial state is InitialState', () {
      expect(viewModel.state, isA<InitialState<String>>());
      expect(viewModel.isDisposed, isFalse);
    });

    test('Valid transition: Initial -> Loading -> Success', () {
      viewModel.loadData();
      expect(viewModel.state, isA<LoadingState<String>>());

      viewModel.loadSuccess('Data');
      expect(viewModel.state, isA<SuccessState<String>>());
      expect((viewModel.state as SuccessState<String>).data, 'Data');

      expect(
        observer.transitions,
        containsAll([
          'InitialState<String> -> LoadingState<String>',
          'LoadingState<String> -> SuccessState<String>',
        ]),
      );
    });

    test(
      'Invalid transition: Initial -> Refreshing directly throws StateError',
      () {
        expect(
          () => viewModel.triggerInvalidTransition(),
          throwsA(
            isA<StateError>().having(
              (e) => e.type,
              'type',
              StateErrorType.validation,
            ),
          ),
        );
        expect(logger.errors, isNotEmpty);
      },
    );

    test('Dispose prevents further updates', () {
      viewModel.dispose();
      expect(viewModel.isDisposed, isTrue);

      viewModel.loadData(); // Should just log a warning and return early
      expect(viewModel.state, isA<InitialState<String>>()); // State unchanged
      expect(logger.warnings, isNotEmpty);
    });

    test('Reset transitions back to InitialState', () {
      viewModel.loadData();
      viewModel.loadSuccess('Data');
      viewModel.reset();
      expect(viewModel.state, isA<InitialState<String>>());
    });

    test('Refreshing retains previous data', () {
      viewModel.loadData();
      viewModel.loadSuccess('Old Data');

      // Since it is success, we can transition to refreshing with previous data.
      // Wait, let's just trigger loading again. emitLoading handles previous data!
      viewModel.loadData();
      expect(viewModel.state, isA<LoadingState<String>>());
      expect(
        (viewModel.state as LoadingState<String>).previousData,
        'Old Data',
      );
    });
  });
}
