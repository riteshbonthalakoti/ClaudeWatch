import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/logging/logging_sink.dart';
import 'package:claudewatch/core/logging/logging_config.dart';

class MockLoggingConfiguration implements LoggingConfiguration {
  @override
  final LogLevel minimumLevel = LogLevel.trace;

  @override
  final List<LogSink> activeSinks = [];
}

class MockLogger implements Logger {
  final List<LogEntry> logs = [];

  @override
  void log({
    required LogLevel level,
    required LogCategory category,
    required String message,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    logs.add(
      LogEntry(
        timestamp: DateTime.now(),
        level: level,
        category: category,
        message: message,
        context: context,
        error: error,
        stackTrace: stackTrace,
      ),
    );
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
