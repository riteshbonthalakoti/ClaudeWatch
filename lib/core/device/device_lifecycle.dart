enum DeviceLifecycleState {
  created,
  scanning,
  discovered,
  pairing,
  connecting,
  connected,
  authenticating,
  ready,
  disconnected,
  reconnecting,
  disposed,
}

class DeviceLifecycle {
  DeviceLifecycleState _state = DeviceLifecycleState.created;

  DeviceLifecycleState get state => _state;

  void transitionTo(DeviceLifecycleState newState) {
    if (!isValidTransition(_state, newState)) {
      throw StateError('Invalid state transition from $_state to $newState');
    }
    _state = newState;
  }

  static bool isValidTransition(
    DeviceLifecycleState from,
    DeviceLifecycleState to,
  ) {
    if (from == DeviceLifecycleState.disposed) {
      return false;
    }
    if (to == DeviceLifecycleState.disposed) {
      return true;
    }
    if (from == to) {
      return true; // Transitioning to the same state is allowed/noop
    }
    switch (from) {
      case DeviceLifecycleState.created:
        return to == DeviceLifecycleState.scanning;
      case DeviceLifecycleState.scanning:
        return to == DeviceLifecycleState.discovered ||
            to == DeviceLifecycleState.disconnected;
      case DeviceLifecycleState.discovered:
        return to == DeviceLifecycleState.pairing ||
            to == DeviceLifecycleState.disconnected;
      case DeviceLifecycleState.pairing:
        return to == DeviceLifecycleState.connecting ||
            to == DeviceLifecycleState.disconnected;
      case DeviceLifecycleState.connecting:
        return to == DeviceLifecycleState.connected ||
            to == DeviceLifecycleState.disconnected;
      case DeviceLifecycleState.connected:
        return to == DeviceLifecycleState.authenticating ||
            to == DeviceLifecycleState.disconnected;
      case DeviceLifecycleState.authenticating:
        return to == DeviceLifecycleState.ready ||
            to == DeviceLifecycleState.disconnected;
      case DeviceLifecycleState.ready:
        return to == DeviceLifecycleState.disconnected;
      case DeviceLifecycleState.disconnected:
        return to == DeviceLifecycleState.reconnecting ||
            to == DeviceLifecycleState.scanning ||
            to == DeviceLifecycleState.connecting;
      case DeviceLifecycleState.reconnecting:
        return to == DeviceLifecycleState.connected ||
            to == DeviceLifecycleState.disconnected;
      case DeviceLifecycleState.disposed:
        return false;
    }
  }
}
