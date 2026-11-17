import 'dart:developer' as developer;
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/logging/logging_sink.dart';

class SimpleLogFormatter implements LogFormatter {
  @override
  String format(LogEntry entry) {
    final buffer = StringBuffer();
    buffer.write('[\${entry.level.name.toUpperCase()}] ');
    buffer.write('[\${entry.category.name.toUpperCase()}] ');
    buffer.write(entry.message);

    if (entry.context != null && entry.context!.data.isNotEmpty) {
      buffer.write(' | Context: \${entry.context!.data}');
    }

    return buffer.toString();
  }
}

class ConsoleLogSink implements LogSink {
  @override
  final String name = 'Console';

  @override
  final LogFormatter formatter;

  @override
  final List<LogFilter> filters;

  ConsoleLogSink({LogFormatter? formatter, this.filters = const []})
    : formatter = formatter ?? SimpleLogFormatter();

  @override
  Future<void> write(LogEntry entry) async {
    final formattedMessage = formatter.format(entry);

    developer.log(
      formattedMessage,
      time: entry.timestamp,
      level: _mapLevelToDeveloperLevel(entry.level),
      name: entry.category.name,
      error: entry.error,
      stackTrace: entry.stackTrace,
    );
  }

  @override
  Future<void> flush() async {
    // Console sink does not require flushing
  }

  @override
  Future<void> close() async {
    // Console sink does not require closing
  }

  int _mapLevelToDeveloperLevel(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 300;
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }
}
