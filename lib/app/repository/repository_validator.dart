/// Validation exception specifically for entity/data validation within repositories.
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  const ValidationException(this.message, {this.fieldErrors});

  @override
  String toString() => "ValidationException: $message";
}

/// Abstract contract for validating data coming into or out of a repository.
abstract interface class RepositoryValidator<T> {
  /// Validates input parameters before executing a query/write.
  void validateInput(Map<String, dynamic> input);

  /// Validates an entity before saving it to the data source.
  void validateEntity(T entity);

  /// Validates output data retrieved from the data source before returning.
  void validateOutput(T data);
}
