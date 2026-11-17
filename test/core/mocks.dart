import 'package:claudewatch/core/di/service_locator.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';

class MockLogger implements Logger {
  final List<String> logs = [];

  @override
  void log({
    required LogLevel level,
    required LogCategory category,
    required String message,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    logs.add('${level.name.toUpperCase()}: $message');
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

class MockServiceLocator implements ServiceLocator {
  final Map<Type, Object> _registry = {};

  @override
  void registerSingleton<T extends Object>(T instance) {
    _registry[T] = instance;
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _registry[T] = factory();
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _registry[T] = factory();
  }

  @override
  T get<T extends Object>() {
    final instance = _registry[T];
    if (instance == null) {
      throw Exception('Service not registered: \$T');
    }
    return instance as T;
  }

  @override
  bool isRegistered<T extends Object>() {
    return _registry.containsKey(T);
  }

  @override
  void unregister<T extends Object>() {
    _registry.remove(T);
  }

  @override
  void allowOverrides(bool allow) {}
}
