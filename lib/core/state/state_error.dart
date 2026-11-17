/// Represents a unified application state error.
class StateError implements Exception {
  final StateErrorType type;
  final String message;
  final Object? originalException;
  final StackTrace? stackTrace;
  final bool isRecoverable;

  const StateError({
    required this.type,
    required this.message,
    this.originalException,
    this.stackTrace,
    this.isRecoverable = true,
  });

  @override
  String toString() => "StateError($type): $message";
}

/// Defines the category of the state error.
enum StateErrorType {
  recoverable,
  fatal,
  validation,
  unexpected,
  offline,
  timeout,
}

/// Contract for processing exceptions into standardized StateErrors.
abstract interface class StateErrorHandler {
  StateError handleError(Object error, [StackTrace? stackTrace]);
}
