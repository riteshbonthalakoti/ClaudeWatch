abstract class NotificationService {
  Future<void> showNotification(String title, String body);
  Future<void> requestPermissions();
}
