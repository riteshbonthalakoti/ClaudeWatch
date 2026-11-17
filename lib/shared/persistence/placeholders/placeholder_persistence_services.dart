import "../../../core/persistence/persistence_contracts.dart";
import "../../../core/persistence/migration_contracts.dart";
import "../../../core/persistence/persistence_observer.dart";
import "../../../app/persistence/persistence_validator.dart";

class PlaceholderDatabaseConnection implements DatabaseConnection {
  @override
  bool get isOpen => true;
  @override
  Future<void> open() async {}
  @override
  Future<void> close() async {}
}

class PlaceholderPersistenceEngine implements PersistenceEngine {
  @override
  DatabaseConnection get connection => PlaceholderDatabaseConnection();
  @override
  Future<void> initialize(PersistenceConfiguration config) async {}
  @override
  Future<void> dispose() async {}
}

class PlaceholderDatabaseProvider implements DatabaseProvider {
  @override
  PersistenceEngine get engine => PlaceholderPersistenceEngine();
}

class PlaceholderMigrationProvider implements MigrationProvider {
  @override
  List<Migration> get pendingMigrations => [];
  @override
  List<Migration> get allMigrations => [];
  @override
  Future<void> executeMigrations(int currentVersion, int targetVersion) async {}
}

class PlaceholderPersistenceObserver implements PersistenceObserver {
  @override
  void onDatabaseOpened(String name) {}
  @override
  void onDatabaseClosed(String name) {}
  @override
  void onMigrationStarted(int fromVersion, int toVersion) {}
  @override
  void onMigrationCompleted(int fromVersion, int toVersion) {}
  @override
  void onMigrationFailed(int fromVersion, int toVersion, Object error) {}
  @override
  void onTransactionStarted(String transactionId) {}
  @override
  void onTransactionCommitted(String transactionId, Duration duration) {}
  @override
  void onTransactionRolledBack(String transactionId, Object error) {}
}

class PlaceholderPersistenceValidator implements PersistenceValidator {
  @override
  void validateConfiguration(PersistenceConfiguration config) {}
  @override
  void validateSchema() {}
  @override
  void validateMigration(Migration migration) {}
  @override
  void validateConnection(DatabaseConnection connection) {}
  @override
  void validateIntegrity() {}
}
