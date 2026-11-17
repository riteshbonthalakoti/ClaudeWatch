/// Represents the severity level of a log entry.
enum LogLevel { trace, debug, info, warning, error, critical }

/// Represents the functional area of the application generating the log.
enum LogCategory {
  application,
  bootstrap,
  navigation,
  state,
  repository,
  persistence,
  services,
  configuration,
  ui,
  performance,
  diagnostics,
  general,
}

/// Optional contextual information attached to a log.
class LogContext {
  final Map<String, dynamic> data;

  const LogContext([this.data = const {}]);

  LogContext copyWith(Map<String, dynamic> newData) {
    return LogContext({...data, ...newData});
  }
}

/// A structured log entry.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final LogCategory category;
  final String message;
  final LogContext? context;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.context,
    this.error,
    this.stackTrace,
  });
}

/// Core interface for application logging.
abstract class Logger {
  void log({
    required LogLevel level,
    required LogCategory category,
    required String message,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  });

  void trace(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  });
  void debug(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  });
  void info(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  });
  void warning(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  });
  void error(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  });
  void critical(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  });
}
