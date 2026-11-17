import "state_error.dart";

/// The base contract for all View States.
sealed class ViewState<T> {
  const ViewState();
}

/// The initial state before any action is taken.
class InitialState<T> extends ViewState<T> {
  const InitialState();
}

/// Represents an active loading state.
class LoadingState<T> extends ViewState<T> {
  final LoadingMode mode;
  final T? previousData;

  const LoadingState({this.mode = LoadingMode.initial, this.previousData});
}

/// Defines the mode of loading to support UI variations (e.g. pull-to-refresh).
enum LoadingMode {
  initial,
  pullToRefresh,
  backgroundRefresh,
  pagination,
  optimistic,
}

/// Depicts an active refreshing state.
class RefreshingState<T> extends ViewState<T> {
  final T? previousData;
  const RefreshingState({this.previousData});
}

/// Represents a successful data retrieval.
class SuccessState<T> extends ViewState<T> {
  final T data;
  const SuccessState(this.data);
}

/// Represents an empty successful state (e.g., empty list).
class EmptyState<T> extends ViewState<T> {
  final String? message;
  const EmptyState({this.message});
}

/// Represents an error state.
class ErrorState<T> extends ViewState<T> {
  final StateError error;
  final T? previousData;

  const ErrorState(this.error, {this.previousData});
}
