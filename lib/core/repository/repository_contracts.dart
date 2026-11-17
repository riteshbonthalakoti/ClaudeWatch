import "repository_result.dart";

/// Base marker interface for all Repositories.
abstract interface class Repository {}

/// Contract for reading data.
abstract interface class ReadRepository<T, ID> implements Repository {
  Future<RepositoryResult<T>> getById(ID id);
  Future<RepositoryResult<List<T>>> getAll();
}

/// Contract for writing/modifying data.
abstract interface class WriteRepository<T, ID> implements Repository {
  Future<RepositoryResult<T>> create(T item);
  Future<RepositoryResult<T>> update(ID id, T item);
  Future<RepositoryResult<bool>> delete(ID id);
}

/// Contract combining Read and Write operations.
abstract interface class CrudRepository<T, ID>
    implements ReadRepository<T, ID>, WriteRepository<T, ID> {}

/// Contract for caching operations.
abstract interface class CacheRepository<T, ID> implements Repository {
  Future<RepositoryResult<T>> getCached(ID id);
  Future<RepositoryResult<void>> putCache(ID id, T item);
  Future<RepositoryResult<void>> invalidateCache(ID id);
  Future<RepositoryResult<void>> clearCache();
}

/// Contract for providing operational context (e.g., transaction boundary, auth state) to repositories.
abstract interface class RepositoryContext {
  String get correlationId;
  Map<String, dynamic> get metadata;
}

/// Contract for creating repositories.
abstract interface class RepositoryFactory {
  T create<T extends Repository>();
}
