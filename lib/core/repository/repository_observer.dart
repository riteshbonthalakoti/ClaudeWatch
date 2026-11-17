import "repository_result.dart";
import "repository_error.dart";

/// Contract for observing repository events (analytics, tracing, logging).
abstract interface class RepositoryObserver {
  /// Called when a repository is created/initialized.
  void onRepositoryCreated(String repositoryName);

  /// Called when a repository is disposed.
  void onRepositoryDisposed(String repositoryName);

  /// Called before a repository operation begins.
  void onOperationStarted(String repositoryName, String operation);

  /// Called when a repository operation completes with a result.
  void onOperationCompleted(
    String repositoryName,
    String operation,
    RepositoryResult result,
    Duration duration,
  );

  /// Called when a repository operation fails directly.
  void onOperationFailed(
    String repositoryName,
    String operation,
    RepositoryException error,
    Duration duration,
  );
}
