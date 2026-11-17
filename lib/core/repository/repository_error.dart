/// Standardized categories for repository errors.
enum RepositoryErrorType {
  validation,
  notFound,
  conflict,
  permission,
  offline,
  timeout,
  cancelled,
  unexpected,
  fatal,
}

/// Unified repository exception object.
class RepositoryException implements Exception {
  final RepositoryErrorType type;
  final String message;
  final Object? originalException;
  final StackTrace? stackTrace;

  const RepositoryException({
    required this.type,
    required this.message,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => "RepositoryException($type): $message";
}
