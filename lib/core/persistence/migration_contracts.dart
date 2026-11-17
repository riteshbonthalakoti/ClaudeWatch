/// Represents a single database migration.
abstract interface class Migration {
  int get version;
  String get description;
  String get checksum;
  List<int> get dependencies;

  Future<void> up();
  Future<void> down();
}

/// Provider responsible for supplying and ordering migrations.
abstract interface class MigrationProvider {
  List<Migration> get pendingMigrations;
  List<Migration> get allMigrations;

  Future<void> executeMigrations(int currentVersion, int targetVersion);
}
