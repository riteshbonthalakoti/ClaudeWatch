import "../../core/persistence/persistence_contracts.dart";
import "../../core/persistence/migration_contracts.dart";

/// Exception thrown during persistence validation.
class PersistenceValidationException implements Exception {
  final String message;
  const PersistenceValidationException(this.message);

  @override
  String toString() => "PersistenceValidationException: $message";
}

/// Abstract contract for validating persistence operations.
abstract interface class PersistenceValidator {
  void validateConfiguration(PersistenceConfiguration config);
  void validateSchema();
  void validateMigration(Migration migration);
  void validateConnection(DatabaseConnection connection);
  void validateIntegrity();
}
