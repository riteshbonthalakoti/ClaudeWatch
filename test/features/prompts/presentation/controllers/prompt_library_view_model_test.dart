import 'package:claudewatch/core/repository/repository_error.dart';
import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:claudewatch/features/prompts/presentation/controllers/prompt_library_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPromptRepository implements PromptRepository {
  List<PromptItem> _items = [];
  bool returnEmpty = false;

  void seed(List<PromptItem> items) {
    _items = List.from(items);
  }

  @override
  Future<RepositoryResult<List<PromptItem>>> fetchAllPrompts() async {
    if (returnEmpty) return RepositorySuccess([]);
    return RepositorySuccess(_items);
  }

  @override
  Future<RepositoryResult<List<PromptItem>>> fetchFavoritePrompts() async {
    return RepositorySuccess(_items.where((p) => p.favorite).toList());
  }

  @override
  Future<RepositoryResult<PromptItem>> fetchPrompt(String id) async {
    return RepositorySuccess(_items.firstWhere((p) => p.id == id));
  }

  @override
  Future<RepositoryResult<List<PromptItem>>> searchLocal(String query) async {
    return RepositorySuccess(_items);
  }

  @override
  Future<RepositoryResult<PromptItem>> toggleFavorite(String id) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = _items[index];
      _items[index] = current.copyWith(favorite: !current.favorite);
      return RepositorySuccess(_items[index]);
    }
    return const RepositoryFailure(
      RepositoryException(
        type: RepositoryErrorType.notFound,
        message: 'Not found',
      ),
    );
  }
}

void main() {
  group('PromptLibraryViewModel Tests', () {
    late MockPromptRepository mockRepository;
    late PromptLibraryViewModel viewModel;

    final dummyPrompts = [
      PromptItem(
        id: '1',
        title: 'Title 1',
        contentPreview: 'Preview 1',
        provider: 'Claude',
        category: 'Coding',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        favorite: true,
      ),
      PromptItem(
        id: '2',
        title: 'Title 2',
        contentPreview: 'Preview 2',
        provider: 'Claude',
        category: 'Writing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        favorite: false,
      ),
    ];

    setUp(() {
      mockRepository = MockPromptRepository();
      mockRepository.seed(dummyPrompts);
      viewModel = PromptLibraryViewModel(mockRepository);
    });

    test('initial state is InitialState', () {
      expect(viewModel.state, isA<InitialState>());
    });

    test('load() emits SuccessState with filtered prompts', () async {
      await viewModel.load();

      expect(viewModel.state, isA<SuccessState<PromptLibraryState>>());
      final stateData = viewModel.currentData;
      expect(stateData.prompts.length, 2);
      expect(stateData.filteredPrompts.length, 2);
    });

    test('load() emits EmptyState if repository returns empty', () async {
      mockRepository.returnEmpty = true;
      await viewModel.load();

      expect(viewModel.state, isA<EmptyState<PromptLibraryState>>());
    });

    test('search() updates searchQuery and filters correctly', () async {
      await viewModel.search('Title 1');

      expect(viewModel.state, isA<SuccessState<PromptLibraryState>>());
      final stateData = viewModel.currentData;
      expect(stateData.searchQuery, 'Title 1');
      expect(stateData.filteredPrompts.length, 1);
      expect(stateData.filteredPrompts.first.id, '1');
    });

    test('filterByCategory() filters correctly', () async {
      await viewModel.load();
      viewModel.filterByCategory('Coding');

      expect(viewModel.state, isA<SuccessState<PromptLibraryState>>());
      final stateData = viewModel.currentData;
      expect(stateData.selectedCategory, 'Coding');
      expect(stateData.filteredPrompts.length, 1);
      expect(stateData.filteredPrompts.first.category, 'Coding');
    });

    test('toggleFavorite updates the item in the list', () async {
      await viewModel.load();
      await viewModel.toggleFavorite('2');

      final stateData = viewModel.currentData;
      final toggled = stateData.prompts.firstWhere((p) => p.id == '2');
      expect(toggled.favorite, true);
    });
  });
}
