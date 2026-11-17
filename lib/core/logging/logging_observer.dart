import 'logging_contracts.dart';
import 'logging_sink.dart';
import 'diagnostics.dart';

/// Observer interface for logging events.
abstract class LoggingObserver {
  void onLogCreated(LogEntry entry);
  void onLogWritten(LogEntry entry, LogSink sink);
  void onLogFiltered(LogEntry entry, LogSink sink, LogFilter filter);
  void onDiagnosticsGenerated(DiagnosticsSnapshot snapshot);
}
