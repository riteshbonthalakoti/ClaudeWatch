import "repository_error.dart";

/// Unified result from a repository operation.
sealed class RepositoryResult<T> {
  const RepositoryResult();
}

/// A fully successful result containing the requested data.
class RepositorySuccess<T> extends RepositoryResult<T> {
  final T data;
  const RepositorySuccess(this.data);
}

/// An operation that failed.
class RepositoryFailure<T> extends RepositoryResult<T> {
  final RepositoryException error;
  const RepositoryFailure(this.error);
}

/// A successful operation that returned empty data (e.g. an empty list).
class RepositoryEmpty<T> extends RepositoryResult<T> {
  const RepositoryEmpty();
}

/// Result returned from local cache (possibly stale).
class RepositoryCached<T> extends RepositoryResult<T> {
  final T data;
  final DateTime timestamp;
  const RepositoryCached(this.data, {required this.timestamp});
}

/// Operation could not complete due to lack of network, but may have returned local data.
class RepositoryOffline<T> extends RepositoryResult<T> {
  final T? localData;
  const RepositoryOffline({this.localData});
}

/// Indicates a stream or operation is still actively loading data.
class RepositoryLoading<T> extends RepositoryResult<T> {
  final double? progress;
  const RepositoryLoading({this.progress});
}

/// Operation succeeded partially (e.g. 2 out of 3 items synced).
class RepositoryPartialSuccess<T> extends RepositoryResult<T> {
  final T data;
  final RepositoryException partialError;
  const RepositoryPartialSuccess(this.data, this.partialError);
}
