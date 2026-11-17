import "package:flutter_test/flutter_test.dart";
import "package:claudewatch/app/persistence/persistence_lifecycle.dart";

class TestPersistenceManager with PersistenceLifecycle {}

void main() {
  group("PersistenceLifecycle Tests", () {
    test("Starts in created state", () {
      final manager = TestPersistenceManager();
      expect(manager.lifecycleState, PersistenceLifecycleState.created);
    });

    test("Valid initialization flow", () {
      final manager = TestPersistenceManager();
      manager.transitionTo(PersistenceLifecycleState.opening);
      manager.transitionTo(PersistenceLifecycleState.opened);
      manager.transitionTo(PersistenceLifecycleState.migrating);
      manager.transitionTo(PersistenceLifecycleState.ready);
      expect(manager.lifecycleState, PersistenceLifecycleState.ready);
    });

    test(
      "Invalid transition from created directly to ready throws StateError",
      () {
        final manager = TestPersistenceManager();
        expect(
          () => manager.transitionTo(PersistenceLifecycleState.ready),
          throwsStateError,
        );
      },
    );

    test("Disposed state prevents further transitions", () {
      final manager = TestPersistenceManager();
      manager.transitionTo(PersistenceLifecycleState.opening);
      manager.transitionTo(PersistenceLifecycleState.disposed);
      expect(manager.lifecycleState, PersistenceLifecycleState.disposed);
      expect(
        () => manager.transitionTo(PersistenceLifecycleState.created),
        throwsStateError,
      );
    });
  });
}
