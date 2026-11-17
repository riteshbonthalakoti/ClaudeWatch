import 'package:claudewatch/core/device/device_lifecycle.dart';
import 'package:claudewatch/core/device/device_request_response.dart';
import 'package:claudewatch/core/device/device_command_event.dart';

abstract class DeviceConnection {
  String get id;
  String get deviceId;
  DeviceLifecycleState get state;
  Stream<DeviceLifecycleState> get onStateChanged;
}

abstract class DeviceSession {
  String get id;
  DeviceConnection get connection;
  DateTime get establishedAt;
  bool get isActive;
}

abstract class DeviceTransport {
  String get name;
  Future<DeviceConnection> connect(String deviceId);
  Future<void> disconnect(String deviceId);
  Future<DeviceResponse> send(String deviceId, DeviceRequest request);
  Stream<DeviceEvent> listenEvents(String deviceId);
}
