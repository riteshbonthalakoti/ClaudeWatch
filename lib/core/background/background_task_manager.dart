abstract class BackgroundTaskManager {
  Future<void> registerPeriodicTask(String id, Duration frequency);
  Future<void> cancelPeriodicTask(String id);
}
