import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/search/domain/models/search_result.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_state.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_view_model.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final SearchViewModel viewModel;

  const SearchScreen({required this.viewModel, super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search prompts and history...',
            border: InputBorder.none,
          ),
          onChanged: (value) => widget.viewModel.search(value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear search',
            onPressed: () {
              _searchController.clear();
              widget.viewModel.clear();
            },
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${(state as ErrorState).error.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EmptyState) {
            return Center(
              child: Text(
                (state as EmptyState).message ?? 'No results found',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final searchState = widget.viewModel.searchState;

          // Initial state with recent searches
          if (state is InitialState || searchState.results.isEmpty) {
            if (searchState.recentSearches.isEmpty) {
              return const Center(
                child: Text(
                  'Start typing to search...',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: searchState.recentSearches.length,
              itemBuilder: (context, index) {
                final recent = searchState.recentSearches[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(recent),
                  onTap: () {
                    _searchController.text = recent;
                    widget.viewModel.search(recent);
                  },
                );
              },
            );
          }

          // Success state with results
          return ListView.builder(
            itemCount: searchState.results.length,
            itemBuilder: (context, index) {
              final result = searchState.results[index];
              return _SearchResultCard(result: result);
            },
          );
        },
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final SearchResult result;

  const _SearchResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final dateStr = '${result.createdAt.month}/${result.createdAt.day} ${result.createdAt.hour}:${result.createdAt.minute.toString().padLeft(2, '0')}';
    final isPrompt = result.sourceType == SearchSourceType.prompt;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPrompt ? Icons.library_books : Icons.history,
                  size: 16,
                  color: isPrompt ? Colors.blueAccent : Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  isPrompt ? 'Prompt' : 'History',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isPrompt ? Colors.blueAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.provider,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (result.subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                result.subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              result.preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
