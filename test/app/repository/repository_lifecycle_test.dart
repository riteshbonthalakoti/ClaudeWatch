import "package:flutter_test/flutter_test.dart";
import "package:claudewatch/app/repository/repository_lifecycle.dart";

class TestRepository with RepositoryLifecycle {}

void main() {
  group("RepositoryLifecycle Tests", () {
    test("Starts in created state", () {
      final repo = TestRepository();
      expect(repo.lifecycleState, RepositoryLifecycleState.created);
    });

    test("Valid initialization flow", () {
      final repo = TestRepository();
      repo.initializeRepository();
      expect(repo.lifecycleState, RepositoryLifecycleState.ready);
    });

    test("Disposed state prevents transitions", () {
      final repo = TestRepository();
      repo.disposeRepository();
      expect(repo.lifecycleState, RepositoryLifecycleState.disposed);
      expect(() => repo.markReady(), throwsStateError);
    });
  });
}
