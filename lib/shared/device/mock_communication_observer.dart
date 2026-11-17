import 'package:claudewatch/core/device/communication_observer.dart';
import 'package:claudewatch/core/device/device_command_event.dart';
import 'package:claudewatch/core/device/device_request_response.dart';

class MockCommunicationObserver implements CommunicationObserver {
  final List<DeviceCommand> sentCommands = [];
  final List<DeviceCommand> receivedCommands = [];
  final List<DeviceEvent> receivedEvents = [];
  final List<DeviceRequest> sentRequests = [];
  final List<DeviceResponse> receivedResponses = [];
  final List<String> errors = [];
  final List<Map<String, dynamic>> metrics = [];

  @override
  void onCommandSent(DeviceCommand command) {
    sentCommands.add(command);
  }

  @override
  void onCommandReceived(DeviceCommand command) {
    receivedCommands.add(command);
  }

  @override
  void onEventReceived(DeviceEvent event) {
    receivedEvents.add(event);
  }

  @override
  void onRequestSent(DeviceRequest request) {
    sentRequests.add(request);
  }

  @override
  void onResponseReceived(DeviceResponse response) {
    receivedResponses.add(response);
  }

  @override
  void onError(String deviceId, Object error, [StackTrace? stackTrace]) {
    errors.add('$deviceId: $error');
  }

  @override
  void onMetricRecorded(String key, double value, [Map<String, String>? tags]) {
    metrics.add({'key': key, 'value': value, 'tags': tags});
  }
}
