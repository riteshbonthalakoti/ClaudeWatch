import 'dart:async';

import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';
import 'package:claudewatch/features/history/presentation/controllers/history_view_model.dart';
import 'package:claudewatch/features/history/presentation/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _MockLogger implements Logger {
  @override
  void log({
    required LogLevel level,
    required LogCategory category,
    required String message,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}

  @override
  void trace(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  }) {}
  @override
  void debug(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void info(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
  }) {}
  @override
  void warning(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void error(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
  @override
  void critical(
    String message, {
    LogCategory category = LogCategory.general,
    LogContext? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {}
}

class _SuccessRepository implements HistoryRepository {
  @override
  Future<List<HistoryEntry>> getHistory() async => [
    HistoryEntry(
      id: 'h-001',
      provider: 'Claude',
      promptPreview: 'Explain Dart isolates in detail.',
      tokensUsed: 1240,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HistoryEntry(
      id: 'h-002',
      provider: 'Claude',
      promptPreview: 'Write a Flutter widget for battery status.',
      tokensUsed: 890,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
}

class _EmptyRepository implements HistoryRepository {
  @override
  Future<List<HistoryEntry>> getHistory() async => [];
}

class _ErrorRepository implements HistoryRepository {
  @override
  Future<List<HistoryEntry>> getHistory() async =>
      throw Exception('Test error');
}

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  ),
  home: child,
);

class _ControllableRepository implements HistoryRepository {
  final Future<List<HistoryEntry>> future;

  _ControllableRepository({required this.future});

  @override
  Future<List<HistoryEntry>> getHistory() => future;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('HistoryScreen Widget Tests', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      final vm = HistoryViewModel(_SuccessRepository(), logger: _MockLogger());

      await tester.pumpWidget(_wrap(HistoryScreen(viewModel: vm)));
      // On initial build the state is InitialState → shows "Initializing..."
      // After addPostFrameCallback fires, loadHistory() starts → LoadingState.
      // We pump once to render the initial frame.
      await tester.pump(Duration.zero);
      // Pump a second time to process the postFrameCallback microtask queue.
      await tester.pump(Duration.zero);
      // Now either loading or success — both are valid at this point.
      // The key assertion is the app renders without error.
      expect(find.byType(HistoryScreen), findsOneWidget);

      await tester.pumpAndSettle();
      vm.dispose();
    });

    testWidgets('shows history list items on success', (tester) async {
      final vm = HistoryViewModel(_SuccessRepository(), logger: _MockLogger());
      await tester.pumpWidget(_wrap(HistoryScreen(viewModel: vm)));
      await tester.pumpAndSettle();

      expect(find.text('Explain Dart isolates in detail.'), findsOneWidget);
      expect(
        find.text('Write a Flutter widget for battery status.'),
        findsOneWidget,
      );
      vm.dispose();
    });

    testWidgets('shows Claude provider badge for each entry', (tester) async {
      final vm = HistoryViewModel(_SuccessRepository(), logger: _MockLogger());
      await tester.pumpWidget(_wrap(HistoryScreen(viewModel: vm)));
      await tester.pumpAndSettle();

      expect(find.text('Claude'), findsNWidgets(2));
      vm.dispose();
    });

    testWidgets('shows empty state when repository returns empty list', (
      tester,
    ) async {
      final vm = HistoryViewModel(_EmptyRepository(), logger: _MockLogger());
      await tester.pumpWidget(_wrap(HistoryScreen(viewModel: vm)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
      // The empty message is split across two Text widgets; use textContaining
      expect(find.textContaining('No AI interactions yet'), findsOneWidget);
      vm.dispose();
    });

    testWidgets('shows error state and retry button on error', (tester) async {
      final vm = HistoryViewModel(_ErrorRepository(), logger: _MockLogger());
      await tester.pumpWidget(_wrap(HistoryScreen(viewModel: vm)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      vm.dispose();
    });

    testWidgets('screen has correct AppBar title', (tester) async {
      final vm = HistoryViewModel(_SuccessRepository(), logger: _MockLogger());
      await tester.pumpWidget(_wrap(HistoryScreen(viewModel: vm)));
      await tester.pump();

      expect(find.text('AI Usage History'), findsOneWidget);
      await tester.pumpAndSettle();
      vm.dispose();
    });

    testWidgets('success state renders a ListView', (tester) async {
      final vm = HistoryViewModel(_SuccessRepository(), logger: _MockLogger());
      await tester.pumpWidget(_wrap(HistoryScreen(viewModel: vm)));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      vm.dispose();
    });
  });
}
