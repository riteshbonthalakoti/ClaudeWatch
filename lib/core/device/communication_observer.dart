import 'package:claudewatch/core/device/device_command_event.dart';
import 'package:claudewatch/core/device/device_request_response.dart';

abstract class CommunicationObserver {
  void onCommandSent(DeviceCommand command);
  void onCommandReceived(DeviceCommand command);
  void onEventReceived(DeviceEvent event);
  void onRequestSent(DeviceRequest request);
  void onResponseReceived(DeviceResponse response);
  void onError(String deviceId, Object error, [StackTrace? stackTrace]);
  void onMetricRecorded(String key, double value, [Map<String, String>? tags]);
}
