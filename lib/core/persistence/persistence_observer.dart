/// Contract for observing persistence events.
abstract interface class PersistenceObserver {
  void onDatabaseOpened(String name);
  void onDatabaseClosed(String name);
  void onMigrationStarted(int fromVersion, int toVersion);
  void onMigrationCompleted(int fromVersion, int toVersion);
  void onMigrationFailed(int fromVersion, int toVersion, Object error);
  void onTransactionStarted(String transactionId);
  void onTransactionCommitted(String transactionId, Duration duration);
  void onTransactionRolledBack(String transactionId, Object error);
}
