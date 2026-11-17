import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/logging/logging_sink.dart';
import 'package:claudewatch/core/logging/logging_observer.dart';
import 'package:claudewatch/core/logging/logging_config.dart';

class AppLoggerImpl implements Logger {
  final LoggingConfiguration configuration;
  final List<LoggingObserver> observers;

  AppLoggerImpl({required this.configuration, this.observers = const []});

  @override
  void log({
    required LogLevel level,
    required LogCategory category,
    required String message,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (level.index < configuration.minimumLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );

    for (final observer in observers) {
      observer.onLogCreated(entry);
    }

    for (final sink in configuration.activeSinks) {
      bool shouldLog = true;
      LogFilter? matchedFilter;

      for (final filter in sink.filters) {
        if (!filter.shouldLog(entry)) {
          shouldLog = false;
          matchedFilter = filter;
          break;
        }
      }

      if (shouldLog) {
        sink.write(entry);
        for (final observer in observers) {
          observer.onLogWritten(entry, sink);
        }
      } else if (matchedFilter != null) {
        for (final observer in observers) {
          observer.onLogFiltered(entry, sink, matchedFilter);
        }
      }
    }
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
