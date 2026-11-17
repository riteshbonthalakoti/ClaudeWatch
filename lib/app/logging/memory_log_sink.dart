import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/core/logging/logging_sink.dart';
import 'dart:collection';

class MemoryLogSink implements LogSink {
  @override
  final String name = 'Memory';

  @override
  final LogFormatter formatter;

  @override
  final List<LogFilter> filters;

  final int maxEntries;
  final Queue<LogEntry> _entries = Queue<LogEntry>();

  MemoryLogSink({
    required this.formatter,
    this.filters = const [],
    this.maxEntries = 1000,
  });

  List<LogEntry> get entries => _entries.toList(growable: false);

  @override
  Future<void> write(LogEntry entry) async {
    if (_entries.length >= maxEntries) {
      _entries.removeFirst();
    }
    _entries.addLast(entry);
  }

  @override
  Future<void> flush() async {
    // Memory sink does not require flushing
  }

  @override
  Future<void> close() async {
    _entries.clear();
  }
}
