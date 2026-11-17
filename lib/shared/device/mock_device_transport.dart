import 'dart:async';
import 'package:claudewatch/core/device/device_lifecycle.dart';
import 'package:claudewatch/core/device/device_request_response.dart';
import 'package:claudewatch/core/device/device_command_event.dart';
import 'package:claudewatch/core/device/device_transport.dart';

class MockDeviceConnection implements DeviceConnection {
  @override
  final String id;
  @override
  final String deviceId;

  DeviceLifecycleState _state = DeviceLifecycleState.created;
  final StreamController<DeviceLifecycleState> _stateController =
      StreamController<DeviceLifecycleState>.broadcast();

  MockDeviceConnection({required this.id, required this.deviceId});

  @override
  DeviceLifecycleState get state => _state;

  @override
  Stream<DeviceLifecycleState> get onStateChanged => _stateController.stream;

  void setState(DeviceLifecycleState newState) {
    if (DeviceLifecycle.isValidTransition(_state, newState)) {
      _state = newState;
      _stateController.add(newState);
    } else {
      throw StateError('Invalid state transition from $_state to $newState');
    }
  }

  void dispose() {
    _stateController.close();
  }
}

class MockDeviceTransport implements DeviceTransport {
  final Map<String, MockDeviceConnection> _connections = {};
  final StreamController<DeviceEvent> _eventController =
      StreamController<DeviceEvent>.broadcast();

  @override
  String get name => 'Mock';

  @override
  Future<DeviceConnection> connect(String deviceId) async {
    final connection = MockDeviceConnection(
      id: 'mock-conn-$deviceId',
      deviceId: deviceId,
    );
    _connections[deviceId] = connection;
    connection.setState(DeviceLifecycleState.connecting);
    connection.setState(DeviceLifecycleState.connected);
    return connection;
  }

  @override
  Future<void> disconnect(String deviceId) async {
    final connection = _connections[deviceId];
    if (connection != null) {
      connection.setState(DeviceLifecycleState.disconnected);
      connection.dispose();
      _connections.remove(deviceId);
    }
  }

  @override
  Future<DeviceResponse> send(String deviceId, DeviceRequest request) async {
    return DeviceResponse(
      requestId: request.id,
      status: DeviceResponseStatus.success,
      payload: {'echo': request.payload},
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<DeviceEvent> listenEvents(String deviceId) {
    return _eventController.stream.where((event) => event.deviceId == deviceId);
  }

  void triggerMockEvent(DeviceEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}
