enum ApplicationServiceLifecycleState {
  created,
  initialized,
  ready,
  executing,
  completed,
  failed,
  disposed,
}

class ApplicationServiceLifecycle {
  ApplicationServiceLifecycleState _state =
      ApplicationServiceLifecycleState.created;

  ApplicationServiceLifecycleState get state => _state;

  void transitionTo(ApplicationServiceLifecycleState newState) {
    if (!isValidTransition(_state, newState)) {
      throw StateError(
        'Invalid service lifecycle transition from $_state to $newState',
      );
    }
    _state = newState;
  }

  static bool isValidTransition(
    ApplicationServiceLifecycleState from,
    ApplicationServiceLifecycleState to,
  ) {
    if (from == ApplicationServiceLifecycleState.disposed) {
      return false;
    }
    if (to == ApplicationServiceLifecycleState.disposed) {
      return true;
    }
    if (from == to) {
      return true;
    }

    switch (from) {
      case ApplicationServiceLifecycleState.created:
        return to == ApplicationServiceLifecycleState.initialized;
      case ApplicationServiceLifecycleState.initialized:
        return to == ApplicationServiceLifecycleState.ready;
      case ApplicationServiceLifecycleState.ready:
        return to == ApplicationServiceLifecycleState.executing;
      case ApplicationServiceLifecycleState.executing:
        return to == ApplicationServiceLifecycleState.completed ||
            to == ApplicationServiceLifecycleState.failed;
      case ApplicationServiceLifecycleState.completed:
      case ApplicationServiceLifecycleState.failed:
        return to == ApplicationServiceLifecycleState.executing ||
            to == ApplicationServiceLifecycleState.ready;
      case ApplicationServiceLifecycleState.disposed:
        return false;
    }
  }
}
