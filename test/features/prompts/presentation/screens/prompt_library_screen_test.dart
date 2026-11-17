import 'package:claudewatch/core/repository/repository_error.dart';
import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/features/prompts/domain/prompt_item.dart';
import 'package:claudewatch/features/prompts/domain/repositories/prompt_repository.dart';
import 'package:claudewatch/features/prompts/presentation/controllers/prompt_library_view_model.dart';
import 'package:claudewatch/features/prompts/presentation/screens/prompt_library_screen.dart';
import 'package:claudewatch/features/prompts/presentation/widgets/prompt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePromptRepository implements PromptRepository {
  @override
  Future<RepositoryResult<List<PromptItem>>> fetchAllPrompts() async =>
      RepositorySuccess([]);
  @override
  Future<RepositoryResult<List<PromptItem>>> fetchFavoritePrompts() async =>
      RepositorySuccess([]);
  @override
  Future<RepositoryResult<PromptItem>> fetchPrompt(String id) async =>
      RepositoryFailure(
        const RepositoryException(
          type: RepositoryErrorType.notFound,
          message: '',
        ),
      );
  @override
  Future<RepositoryResult<List<PromptItem>>> searchLocal(String query) async =>
      RepositorySuccess([]);
  @override
  Future<RepositoryResult<PromptItem>> toggleFavorite(String id) async =>
      RepositoryFailure(
        const RepositoryException(
          type: RepositoryErrorType.notFound,
          message: '',
        ),
      );
}

class TestPromptLibraryViewModel extends PromptLibraryViewModel {
  TestPromptLibraryViewModel() : super(_FakePromptRepository());

  void setState(ViewState<PromptLibraryState> newState) {
    // using the protected emit method from ViewModel
    // Note: emit is protected, so we might need a workaround.
    // Instead of forcing state, let's just create a custom stream or mock it better.
    // Actually, emit is protected, but we are inside a subclass, so we can call it!
    emit(newState);
  }
}

void main() {
  group('PromptLibraryScreen Tests', () {
    late TestPromptLibraryViewModel viewModel;

    Widget createScreen() {
      return MaterialApp(home: PromptLibraryScreen(viewModel: viewModel));
    }

    setUp(() {
      viewModel = TestPromptLibraryViewModel();
    });

    testWidgets('shows loading indicator on loading state', (
      WidgetTester tester,
    ) async {
      viewModel.setState(const LoadingState<PromptLibraryState>());

      await tester.pumpWidget(createScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no prompts found', (
      WidgetTester tester,
    ) async {
      viewModel.setState(
        const EmptyState<PromptLibraryState>(message: 'No prompts found.'),
      );

      await tester.pumpWidget(createScreen());

      expect(find.text('No prompts found.'), findsOneWidget);
    });

    testWidgets('shows prompts correctly on success', (
      WidgetTester tester,
    ) async {
      final prompts = [
        PromptItem(
          id: '1',
          title: 'Test Prompt 1',
          contentPreview: 'Preview',
          provider: 'Claude',
          category: 'Coding',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      viewModel.setState(const LoadingState<PromptLibraryState>());
      viewModel.setState(
        SuccessState<PromptLibraryState>(
          PromptLibraryState(prompts: prompts, filteredPrompts: prompts),
        ),
      );

      await tester.pumpWidget(createScreen());

      expect(find.byType(PromptCard), findsOneWidget);
      expect(find.text('Test Prompt 1'), findsOneWidget);
    });
  });
}
