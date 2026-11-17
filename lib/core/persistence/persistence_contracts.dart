/// Configuration for initializing the persistence layer.
abstract interface class PersistenceConfiguration {
  String get databaseName;
  int get version;
  bool get enableLogging;
  bool get requireEncryption;
}

/// Information about the storage mechanism.
abstract interface class StorageInfo {
  int get sizeInBytes;
  int get freeSpaceInBytes;
  String get path;
}

/// A connection boundary.
abstract interface class DatabaseConnection {
  bool get isOpen;
  Future<void> open();
  Future<void> close();
}

/// A working session on the database.
abstract interface class DatabaseSession {
  Future<T> execute<T>(Future<T> Function() action);
}

/// The core Engine provider interface to be implemented by Drift/Hive/Isar wrappers.
abstract interface class PersistenceEngine {
  DatabaseConnection get connection;
  Future<void> initialize(PersistenceConfiguration config);
  Future<void> dispose();
}

/// Interface for repositories to get the active Engine/Connection.
abstract interface class DatabaseProvider {
  PersistenceEngine get engine;
}
