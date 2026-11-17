import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:claudewatch/features/prompts/presentation/controllers/prompt_library_view_model.dart';
import 'package:claudewatch/features/prompts/presentation/widgets/prompt_card.dart';
import 'package:claudewatch/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class PromptLibraryScreen extends StatefulWidget {
  final PromptLibraryViewModel viewModel;

  const PromptLibraryScreen({super.key, required this.viewModel});

  @override
  State<PromptLibraryScreen> createState() => _PromptLibraryScreenState();
}

class _PromptLibraryScreenState extends State<PromptLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Favorites',
    'Coding',
    'Writing',
    'Research',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is InitialState) {
        widget.viewModel.load();
      }
    });
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
        title: const Text('Prompt Library'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search prompts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    widget.viewModel.search('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => widget.viewModel.search(value),
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final state = widget.viewModel.state;

          return Column(
            children: [
              _buildCategoryChips(
                widget.viewModel.currentData.selectedCategory,
              ),
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(String selectedCategory) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: _categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  widget.viewModel.filterByCategory(category);
                } else if (category != 'All') {
                  // If deselecting a category, go back to All
                  widget.viewModel.filterByCategory('All');
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(ViewState<PromptLibraryState> state) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ErrorState) {
      return _buildErrorState((state as ErrorState).error.message);
    }

    if (state is EmptyState) {
      final emptyState = state as EmptyState<PromptLibraryState>;
      return _buildEmptyState(emptyState.message, Icons.library_books);
    }

    if (state is SuccessState<PromptLibraryState>) {
      return _buildSuccessList(state.data.filteredPrompts);
    }

    return const Center(child: Text('Initializing...'));
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'search_off':
        return Icons.search_off;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'category':
        return Icons.category;
      default:
        return Icons.library_books;
    }
  }

  Widget _buildSuccessList(List<PromptItem> prompts) {
    return RefreshIndicator(
      onRefresh: () async => widget.viewModel.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return PromptCard(
            prompt: prompt,
            onFavoriteToggled: () => widget.viewModel.toggleFavorite(prompt.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String? message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'No prompts found.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              onPressed: () => widget.viewModel.load(),
            ),
          ],
        ),
      ),
    );
  }
}
