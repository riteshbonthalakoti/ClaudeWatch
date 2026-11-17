import 'package:claudewatch/core/analytics/analytics_tracker.dart';
import 'package:claudewatch/core/background/background_task_manager.dart';
import 'package:claudewatch/core/navigation/app_router.dart';
import 'package:claudewatch/core/notifications/notification_service.dart';
import 'package:claudewatch/core/persistence/local_storage.dart';
import 'package:claudewatch/core/sync/sync_manager.dart';
import 'package:claudewatch/core/state/state_error.dart';
import 'package:claudewatch/core/state/view_state.dart';
import 'package:claudewatch/core/state/state_observer.dart';
import 'package:claudewatch/core/repository/repository_observer.dart';
import 'package:claudewatch/core/repository/repository_result.dart';
import 'package:claudewatch/core/repository/repository_error.dart';
import 'package:claudewatch/app/repository/repository_transaction.dart';

class PlaceholderRouter implements AppRouter {
  @override
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async => null;
  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async => null;
  @override
  void pop<T extends Object?>([T? result]) {}
  @override
  void goBack() {}
}

class PlaceholderLocalStorage implements LocalStorage {
  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> delete(String key) async {}
  @override
  Future<void> clear() async {}
}

class PlaceholderAnalytics implements AnalyticsTracker {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {}
  @override
  Future<void> setUserProperty(String name, String value) async {}
  @override
  Future<void> setUserId(String userId) async {}
}

class PlaceholderNotificationService implements NotificationService {
  @override
  Future<void> showNotification(String title, String body) async {}
  @override
  Future<void> requestPermissions() async {}
}

class PlaceholderBackgroundTaskManager implements BackgroundTaskManager {
  @override
  Future<void> registerPeriodicTask(String id, Duration frequency) async {}
  @override
  Future<void> cancelPeriodicTask(String id) async {}
}

class PlaceholderSyncManager implements SyncManager {
  @override
  Future<void> synchronize() async {}
  @override
  Stream<bool> get isSyncing => const Stream.empty();
}

class PlaceholderStateObserver implements StateObserver {
  @override
  void onViewModelCreated(String viewModelName) {}

  @override
  void onViewModelDisposed(String viewModelName) {}

  @override
  void onTransition(String viewModelName, StateTransition transition) {}

  @override
  void onStateChanged(String viewModelName, ViewState currentState) {}

  @override
  void onError(String viewModelName, StateError error) {}
}

class PlaceholderStateErrorHandler implements StateErrorHandler {
  @override
  StateError handleError(Object error, [StackTrace? stackTrace]) {
    return StateError(
      type: StateErrorType.unexpected,
      message: error.toString(),
      originalException: error,
      stackTrace: stackTrace,
    );
  }
}

class PlaceholderRepositoryObserver implements RepositoryObserver {
  @override
  void onRepositoryCreated(String repositoryName) {}

  @override
  void onRepositoryDisposed(String repositoryName) {}

  @override
  void onOperationStarted(String repositoryName, String operation) {}

  @override
  void onOperationCompleted(
    String repositoryName,
    String operation,
    RepositoryResult result,
    Duration duration,
  ) {}

  @override
  void onOperationFailed(
    String repositoryName,
    String operation,
    RepositoryException error,
    Duration duration,
  ) {}
}

class PlaceholderTransaction implements RepositoryTransaction {
  @override
  final String transactionId = "txn-000";

  @override
  Future<void> commit() async {}

  @override
  Future<void> rollback() async {}
}

class PlaceholderTransactionManager implements TransactionManager {
  @override
  Future<RepositoryTransaction> beginTransaction({
    bool requiresNew = false,
  }) async {
    return PlaceholderTransaction();
  }
}
