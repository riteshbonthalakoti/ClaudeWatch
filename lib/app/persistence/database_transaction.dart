/// Represents a database transaction in the persistence layer.
abstract interface class DatabaseTransaction {
  String get transactionId;

  Future<void> begin({bool nested = false});
  Future<void> commit();
  Future<void> rollback();
  Future<void> cancel();

  bool get isActive;
  bool get isRolledBack;
}
