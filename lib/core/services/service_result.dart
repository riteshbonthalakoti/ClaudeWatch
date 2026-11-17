enum ApplicationServiceResultStatus {
  success,
  failure,
  partial,
  cancelled,
  offline,
  validationFailure,
  unexpectedFailure,
}

class ApplicationServiceResult<T> {
  final ApplicationServiceResultStatus status;
  final T? data;
  final String? message;
  final Exception? exception;

  const ApplicationServiceResult.success(this.data, {this.message})
    : status = ApplicationServiceResultStatus.success,
      exception = null;

  const ApplicationServiceResult.failure(
    this.exception, {
    this.message,
    this.status = ApplicationServiceResultStatus.failure,
  }) : data = null;

  const ApplicationServiceResult.partial(this.data, {this.message})
    : status = ApplicationServiceResultStatus.partial,
      exception = null;

  const ApplicationServiceResult.cancelled({this.message})
    : status = ApplicationServiceResultStatus.cancelled,
      data = null,
      exception = null;

  const ApplicationServiceResult.offline({this.message})
    : status = ApplicationServiceResultStatus.offline,
      data = null,
      exception = null;

  const ApplicationServiceResult.validationFailure({this.message})
    : status = ApplicationServiceResultStatus.validationFailure,
      data = null,
      exception = null;

  const ApplicationServiceResult.unexpected(this.exception, {this.message})
    : status = ApplicationServiceResultStatus.unexpectedFailure,
      data = null;
}

class ApplicationServiceException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  ApplicationServiceException(
    this.message, [
    this.originalError,
    this.stackTrace,
  ]);

  @override
  String toString() => 'ApplicationServiceException: $message';
}
