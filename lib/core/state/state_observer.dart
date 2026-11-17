import "view_state.dart";
import "state_error.dart";

/// Defines a transition between two ViewStates.
class StateTransition<T> {
  final ViewState<T> currentState;
  final ViewState<T> nextState;

  const StateTransition({required this.currentState, required this.nextState});
}

/// Contract for observing state changes across the application.
abstract interface class StateObserver {
  /// Called when a view model is initialized.
  void onViewModelCreated(String viewModelName);

  /// Called when a view model is disposed.
  void onViewModelDisposed(String viewModelName);

  /// Called before a state transition occurs.
  void onTransition(String viewModelName, StateTransition transition);

  /// Called after a state has changed.
  void onStateChanged(String viewModelName, ViewState currentState);

  /// Called when an error occurs during state management.
  void onError(String viewModelName, StateError error);
}
