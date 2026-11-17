import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:claudewatch/features/history/domain/repositories/history_repository.dart';
import 'package:claudewatch/features/history/presentation/controllers/history_view_model.dart';
import 'package:claudewatch/shared/logging/mock_logging.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeHistoryRepository implements HistoryRepository {
  final List<HistoryEntry> entries;
  final bool shouldThrow;

  _FakeHistoryRepository({this.entries = const [], this.shouldThrow = false});

  @override
  Future<List<HistoryEntry>> getHistory() async {
    if (shouldThrow) throw Exception('Network error');
    return entries;
  }
}

final _sampleEntries = [
  HistoryEntry(
    id: 'h-001',
    provider: 'Claude',
    promptPreview: 'Test prompt one',
    tokensUsed: 500,
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  HistoryEntry(
    id: 'h-002',
    provider: 'Claude',
    promptPreview: 'Test prompt two',
    tokensUsed: 800,
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('HistoryViewModel Tests', () {
    test('initial state is InitialState', () {
      final vm = HistoryViewModel(
        _FakeHistoryRepository(entries: _sampleEntries),
        logger: MockLogger(),
      );
      expect(vm.state, isA<InitialState<List<HistoryEntry>>>());
      vm.dispose();
    });

    test('loadHistory transitions Initial → Loading → Success', () async {
      final vm = HistoryViewModel(
        _FakeHistoryRepository(entries: _sampleEntries),
        logger: MockLogger(),
      );

      final states = <ViewState<List<HistoryEntry>>>[];
      vm.addListener(() => states.add(vm.state));

      await vm.loadHistory();

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states.first, isA<LoadingState<List<HistoryEntry>>>());
      expect(states.last, isA<SuccessState<List<HistoryEntry>>>());

      final success = states.last as SuccessState<List<HistoryEntry>>;
      expect(success.data.length, equals(2));
      vm.dispose();
    });

    test(
      'loadHistory emits EmptyState when repository returns empty list',
      () async {
        final vm = HistoryViewModel(
          _FakeHistoryRepository(entries: []),
          logger: MockLogger(),
        );

        await vm.loadHistory();

        expect(vm.state, isA<EmptyState<List<HistoryEntry>>>());
        vm.dispose();
      },
    );

    test('loadHistory emits ErrorState on repository exception', () async {
      final vm = HistoryViewModel(
        _FakeHistoryRepository(shouldThrow: true),
        logger: MockLogger(),
      );

      await vm.loadHistory();

      expect(vm.state, isA<ErrorState<List<HistoryEntry>>>());
      final errState = vm.state as ErrorState<List<HistoryEntry>>;
      expect(errState.error.message, contains('Failed to load history'));
      vm.dispose();
    });

    test('refresh() calls loadHistory again', () async {
      var callCount = 0;
      final repo = _CountingHistoryRepository(
        entries: _sampleEntries,
        onCall: () => callCount++,
      );
      final vm = HistoryViewModel(repo, logger: MockLogger());

      await vm.loadHistory(); // first call
      callCount = 0; // reset counter

      await vm.refresh();
      expect(callCount, equals(1));
      vm.dispose();
    });

    test('notifyListeners is called on each state change', () async {
      final vm = HistoryViewModel(
        _FakeHistoryRepository(entries: _sampleEntries),
        logger: MockLogger(),
      );
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);

      await vm.loadHistory();

      // Expect at least 2 notifications: Loading + Success
      expect(notifyCount, greaterThanOrEqualTo(2));
      vm.dispose();
    });
  });
}

class _CountingHistoryRepository implements HistoryRepository {
  final List<HistoryEntry> entries;
  final VoidCallback onCall;

  _CountingHistoryRepository({required this.entries, required this.onCall});

  @override
  Future<List<HistoryEntry>> getHistory() async {
    onCall();
    return entries;
  }
}

// ignore: avoid_private_typedef_functions
typedef VoidCallback = void Function();
