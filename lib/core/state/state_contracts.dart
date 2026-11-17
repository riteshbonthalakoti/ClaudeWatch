import "view_state.dart";

/// Contract for objects that represent an Application State (global state).
abstract interface class ApplicationState {}

/// Contract for managing state and holding data.
abstract interface class StateStore<T> {
  ViewState<T> get state;
  void setState(ViewState<T> newState);
}

/// Contract for notifying listeners of state changes.
abstract interface class StateNotifier<T> {
  void addListener(void Function(ViewState<T> state) listener);
  void removeListener(void Function(ViewState<T> state) listener);
}

/// Contract for factoring complex states.
abstract interface class StateFactory<T> {
  ViewState<T> createInitialState();
}

/// Contract for states that require cleanup.
abstract interface class DisposableState {
  void dispose();
}
