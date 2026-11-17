import 'logging_sink.dart';
import 'logging_contracts.dart';

/// Configuration for the logging system.
abstract class LoggingConfiguration {
  /// The minimum log level to process globally.
  LogLevel get minimumLevel;

  /// The list of active sinks for the application.
  List<LogSink> get activeSinks;
}
