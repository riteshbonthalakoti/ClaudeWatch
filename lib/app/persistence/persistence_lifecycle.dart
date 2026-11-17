/// Database lifecycle states.
enum PersistenceLifecycleState {
  created,
  opening,
  opened,
  migrating,
  ready,
  closing,
  closed,
  failed,
  disposed,
}

/// Manages the state machine of the persistence layer.
mixin PersistenceLifecycle {
  PersistenceLifecycleState _state = PersistenceLifecycleState.created;

  PersistenceLifecycleState get lifecycleState => _state;

  void transitionTo(PersistenceLifecycleState nextState) {
    if (_state == PersistenceLifecycleState.disposed) {
      throw StateError("Cannot transition from disposed persistence state.");
    }

    // Enforce logical transitions
    if (_state == PersistenceLifecycleState.created &&
        nextState != PersistenceLifecycleState.opening) {
      throw StateError("Must transition to opening from created.");
    }

    if (_state == PersistenceLifecycleState.opened &&
        (nextState != PersistenceLifecycleState.migrating &&
            nextState != PersistenceLifecycleState.ready)) {
      throw StateError("Opened database must migrate or become ready.");
    }

    _state = nextState;
  }
}
