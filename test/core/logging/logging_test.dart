import 'package:flutter_test/flutter_test.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/logging/logging_sink.dart';
import 'package:claudewatch/core/logging/logging_observer.dart';
import 'package:claudewatch/core/logging/diagnostics.dart';
import 'package:claudewatch/app/logging/app_logger_impl.dart';
import 'package:claudewatch/app/logging/memory_log_sink.dart';
import 'package:claudewatch/app/logging/console_log_sink.dart';
import 'package:claudewatch/app/logging/simple_diagnostics_provider.dart';
import 'package:claudewatch/shared/logging/mock_logging.dart';
import 'package:claudewatch/app/bootstrap/bootstrap.dart';

class TestFilter implements LogFilter {
  final LogLevel minimumLevel;
  TestFilter(this.minimumLevel);

  @override
  bool shouldLog(LogEntry entry) {
    return entry.level.index >= minimumLevel.index;
  }
}

class TestObserver implements LoggingObserver {
  final List<LogEntry> createdLogs = [];
  final List<LogEntry> writtenLogs = [];
  final List<LogEntry> filteredLogs = [];

  @override
  void onLogCreated(LogEntry entry) => createdLogs.add(entry);

  @override
  void onLogWritten(LogEntry entry, LogSink sink) => writtenLogs.add(entry);

  @override
  void onLogFiltered(LogEntry entry, LogSink sink, LogFilter filter) =>
      filteredLogs.add(entry);

  @override
  void onDiagnosticsGenerated(DiagnosticsSnapshot snapshot) {}
}

void main() {
  group('Logging & Diagnostics Foundation', () {
    test('AppLoggerImpl routes logs to sinks', () async {
      final config = MockLoggingConfiguration();
      final sink = MemoryLogSink(formatter: SimpleLogFormatter());
      config.activeSinks.add(sink);

      final logger = AppLoggerImpl(configuration: config);

      logger.info('Test Info Message', category: LogCategory.application);

      expect(sink.entries.length, 1);
      expect(sink.entries.first.message, 'Test Info Message');
      expect(sink.entries.first.level, LogLevel.info);
    });

    test('Log filters correctly block logs', () async {
      final config = MockLoggingConfiguration();
      final sink = MemoryLogSink(
        formatter: SimpleLogFormatter(),
        filters: [TestFilter(LogLevel.warning)],
      );
      config.activeSinks.add(sink);

      final observer = TestObserver();
      final logger = AppLoggerImpl(
        configuration: config,
        observers: [observer],
      );

      logger.info('Should be filtered');
      logger.error('Should pass');

      expect(sink.entries.length, 1);
      expect(sink.entries.first.level, LogLevel.error);

      expect(observer.createdLogs.length, 2);
      expect(observer.writtenLogs.length, 1);
      expect(observer.filteredLogs.length, 1);
    });

    test('DiagnosticsProvider aggregates basic data', () async {
      final provider = SimpleDiagnosticsProvider();

      final snapshot = await provider.generateSnapshot();

      expect(snapshot.appVersion, isNotEmpty);
      expect(snapshot.environment, isNotEmpty);
      expect(snapshot.buildMode, isNotEmpty);
      expect(snapshot.memoryUsagePlaceholder, isNotEmpty);
    });

    test('Bootstrapper registers logging properly', () async {
      final bootstrapper = AppBootstrapper();
      final locator = await bootstrapper.bootstrap();

      expect(locator.isRegistered<Logger>(), true);
      expect(locator.isRegistered<DiagnosticsProvider>(), true);
    });
  });
}
