import 'package:flutter/foundation.dart';
import '../../core/state/view_state.dart';
import '../../core/state/state_error.dart';
import '../../core/state/state_observer.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';

/// Base class for all ViewModels, abstracting away the state management package.
abstract class ViewModel<T> {
  final StateObserver? _observer;
  final Logger _logger;

  ViewState<T> _state;
  bool _isDisposed = false;

  ViewModel(this._observer, this._logger) : _state = InitialState<T>() {
    _observer?.onViewModelCreated(runtimeType.toString());
    initialize();
  }

  ViewState<T> get state => _state;
  bool get isDisposed => _isDisposed;

  /// Hook for subclasses to initialize resources.
  @protected
  void initialize() {}

  /// Hook for subclasses to clean up resources.
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _observer?.onViewModelDisposed(runtimeType.toString());
  }

  /// Refreshes the data. Should be overridden by subclasses that support refreshing.
  void refresh() {}

  /// Resets the view model to its initial state.
  @mustCallSuper
  void reset() {
    _updateState(InitialState<T>());
  }

  /// Retries a failed operation. Usually used when in ErrorState.
  void retry() {}

  /// Lifecycle hooks
  void onStart() {}
  void onResume() {}
  void onPause() {}
  void onBackground() {}
  void onForeground() {}

  /// Core state transition method. Validates transition before applying.
  @protected
  void emit(ViewState<T> newState) {
    _updateState(newState);
  }

  /// Emits a loading state.
  @protected
  void emitLoading({LoadingMode mode = LoadingMode.initial}) {
    T? currentData;
    if (_state is SuccessState<T>) {
      currentData = (_state as SuccessState<T>).data;
    } else if (_state is RefreshingState<T>) {
      currentData = (_state as RefreshingState<T>).previousData;
    } else if (_state is ErrorState<T>) {
      currentData = (_state as ErrorState<T>).previousData;
    }

    emit(LoadingState<T>(mode: mode, previousData: currentData));
  }

  /// Emits a success state.
  @protected
  void emitSuccess(T data) {
    emit(SuccessState<T>(data));
  }

  /// Emits an empty state.
  @protected
  void emitEmpty([String? message]) {
    emit(EmptyState<T>(message: message));
  }

  /// Emits an error state.
  @protected
  void emitError(StateError error) {
    _observer?.onError(runtimeType.toString(), error);
    T? currentData;
    if (_state is SuccessState<T>) {
      currentData = (_state as SuccessState<T>).data;
    } else if (_state is RefreshingState<T>) {
      currentData = (_state as RefreshingState<T>).previousData;
    } else if (_state is LoadingState<T>) {
      currentData = (_state as LoadingState<T>).previousData;
    }

    emit(ErrorState<T>(error, previousData: currentData));
  }

  void _updateState(ViewState<T> newState) {
    if (_isDisposed) {
      _logger.warning(
        'Attempted to update state on disposed ViewModel: $runtimeType',
      );
      return;
    }

    if (!_isValidTransition(_state, newState)) {
      final errorMsg =
          'Invalid state transition from ${_state.runtimeType} to ${newState.runtimeType} in $runtimeType';
      _logger.error(errorMsg);
      throw StateError(type: StateErrorType.validation, message: errorMsg);
    }

    final transition = StateTransition<T>(
      currentState: _state,
      nextState: newState,
    );
    _observer?.onTransition(runtimeType.toString(), transition);

    _state = newState;

    _observer?.onStateChanged(runtimeType.toString(), _state);

    onStateUpdated();
  }

  /// Internal hook called after state updates.
  /// Subclasses or mixins can use this to notify UI frameworks.
  @protected
  void onStateUpdated() {}

  /// Validates if a transition is allowed.
  bool _isValidTransition(ViewState<T> current, ViewState<T> next) {
    // Initializing state can transition to Loading or Error.
    if (current is InitialState<T>) {
      return next is LoadingState<T> ||
          next is ErrorState<T> ||
          next is InitialState<T> ||
          next is EmptyState<T>;
    }

    // Disallow transition from anything but Success/Error to Refreshing,
    // unless there is previous data.
    if (next is RefreshingState<T>) {
      if (current is! SuccessState<T> &&
          current is! ErrorState<T> &&
          current is! RefreshingState<T>) {
        if (next.previousData == null) {
          return false;
        }
      }
    }

    return true;
  }
}
