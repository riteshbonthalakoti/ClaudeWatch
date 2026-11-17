abstract class SyncManager {
  Future<void> synchronize();
  Stream<bool> get isSyncing;
}
