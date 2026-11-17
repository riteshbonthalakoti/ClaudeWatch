import 'logging_contracts.dart';

/// Formats a LogEntry into a string representation for a specific sink.
abstract class LogFormatter {
  String format(LogEntry entry);
}

/// Determines if a LogEntry should be processed by a specific sink.
abstract class LogFilter {
  bool shouldLog(LogEntry entry);
}

/// Defines where logs are outputted (e.g., Console, Memory, File).
abstract class LogSink {
  String get name;
  LogFormatter get formatter;
  List<LogFilter> get filters;

  /// Writes the entry to the sink if it passes filters.
  Future<void> write(LogEntry entry);

  /// Flushes any buffered logs.
  Future<void> flush();

  /// Closes the sink and releases resources.
  Future<void> close();
}
