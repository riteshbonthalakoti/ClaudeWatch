/// Represents a transaction that can be committed or rolled back.
abstract interface class RepositoryTransaction {
  /// The unique identifier for this transaction.
  String get transactionId;

  /// Commits the transaction.
  Future<void> commit();

  /// Rolls back the transaction.
  Future<void> rollback();
}

/// Manages beginning transactions.
abstract interface class TransactionManager {
  /// Begins a new transaction, potentially supporting nested transactions.
  Future<RepositoryTransaction> beginTransaction({bool requiresNew = false});
}
