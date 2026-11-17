/// Represents the lifecycle states of a Repository.
enum RepositoryLifecycleState {
  created,
  initialized,
  ready,
  refreshing,
  synchronizing,
  disposed,
}

/// Mixin for managing the lifecycle of a repository.
mixin RepositoryLifecycle {
  RepositoryLifecycleState _state = RepositoryLifecycleState.created;

  RepositoryLifecycleState get lifecycleState => _state;

  void initializeRepository() {
    _transitionTo(RepositoryLifecycleState.initialized);
    _transitionTo(RepositoryLifecycleState.ready);
  }

  void markRefreshing() {
    _transitionTo(RepositoryLifecycleState.refreshing);
  }

  void markSynchronizing() {
    _transitionTo(RepositoryLifecycleState.synchronizing);
  }

  void markReady() {
    _transitionTo(RepositoryLifecycleState.ready);
  }

  void disposeRepository() {
    _transitionTo(RepositoryLifecycleState.disposed);
  }

  void _transitionTo(RepositoryLifecycleState nextState) {
    if (_state == RepositoryLifecycleState.disposed) {
      throw StateError("Cannot transition from disposed state in Repository.");
    }

    // Prevent invalid transitions (e.g., initialized directly to synchronizing without ready)
    if (_state == RepositoryLifecycleState.initialized &&
        (nextState == RepositoryLifecycleState.synchronizing ||
            nextState == RepositoryLifecycleState.refreshing)) {
      throw StateError("Repository must be ready before syncing/refreshing.");
    }

    _state = nextState;
  }
}
