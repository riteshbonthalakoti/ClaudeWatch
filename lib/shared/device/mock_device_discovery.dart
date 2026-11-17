import 'dart:async';
import 'package:claudewatch/core/device/device_discovery.dart';

class MockDeviceScanner implements DeviceScanner {
  final StreamController<List<DeviceDiscovery>> _controller =
      StreamController<List<DeviceDiscovery>>.broadcast();
  bool _isScanning = false;

  @override
  Stream<List<DeviceDiscovery>> get onDiscoveredDevices => _controller.stream;

  @override
  bool get isScanning => _isScanning;

  @override
  Future<void> startScan() async {
    _isScanning = true;
    _controller.add([
      const DeviceDiscovery(
        id: 'dev-1',
        name: 'ClaudeWatch v1',
        address: 'AA:BB:CC:11:22:33',
        rssi: -65,
      ),
      const DeviceDiscovery(
        id: 'dev-2',
        name: 'ClaudeWatch v2',
        address: 'AA:BB:CC:44:55:66',
        rssi: -80,
      ),
    ]);
  }

  @override
  Future<void> stopScan() async {
    _isScanning = false;
  }

  void dispose() {
    _controller.close();
  }
}

class MockDevicePairing implements DevicePairing {
  final Set<String> _pairedDevices = {};

  @override
  Future<bool> pair(String deviceId) async {
    _pairedDevices.add(deviceId);
    return true;
  }

  @override
  Future<bool> unpair(String deviceId) async {
    _pairedDevices.remove(deviceId);
    return true;
  }

  @override
  Future<bool> isPaired(String deviceId) async {
    return _pairedDevices.contains(deviceId);
  }
}

class MockDeviceAuthentication implements DeviceAuthentication {
  final Set<String> _authenticatedDevices = {};

  @override
  Future<bool> authenticate(
    String deviceId,
    Map<String, dynamic> credentials,
  ) async {
    if (credentials['pin'] == '1234' || credentials['token'] == 'valid_token') {
      _authenticatedDevices.add(deviceId);
      return true;
    }
    return false;
  }

  @override
  Future<bool> isAuthenticated(String deviceId) async {
    return _authenticatedDevices.contains(deviceId);
  }
}
