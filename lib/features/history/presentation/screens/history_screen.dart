import 'package:flutter/material.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/history/domain/models/history_entry.dart';
import 'package:claudewatch/features/history/presentation/controllers/history_view_model.dart';
import 'package:claudewatch/features/history/presentation/widgets/history_entry_card.dart';
import 'package:claudewatch/shared/widgets/primary_button.dart';

/// The AI Usage History screen.
///
/// Displays a scrollable list of past AI interactions retrieved through
/// [HistoryViewModel]. No business logic lives in this widget.
class HistoryScreen extends StatefulWidget {
  final HistoryViewModel viewModel;

  const HistoryScreen({super.key, required this.viewModel});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is InitialState) {
        widget.viewModel.loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Usage History'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => widget.viewModel.loadHistory(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final state = widget.viewModel.state;

          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ErrorState) {
            return _buildErrorState(
              (state as ErrorState<List<HistoryEntry>>).error.message,
            );
          }

          if (state is EmptyState) {
            return _buildEmptyState(
              (state as EmptyState<List<HistoryEntry>>).message,
            );
          }

          if (state is SuccessState<List<HistoryEntry>>) {
            return _buildSuccessList(state.data);
          }

          return const Center(child: Text('Initializing...'));
        },
      ),
    );
  }

  Widget _buildSuccessList(List<HistoryEntry> entries) {
    return RefreshIndicator(
      onRefresh: () async => widget.viewModel.loadHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: entries.length,
        itemBuilder: (context, index) =>
            HistoryEntryCard(entry: entries[index]),
      ),
    );
  }

  Widget _buildEmptyState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'No AI interactions yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start using Claude widgets to see your history here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Retry',
              onPressed: () => widget.viewModel.loadHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
