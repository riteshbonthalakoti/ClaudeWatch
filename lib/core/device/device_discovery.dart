class DeviceDiscovery {
  final String id;
  final String name;
  final String address;
  final int rssi;
  final Map<String, dynamic> metadata;

  const DeviceDiscovery({
    required this.id,
    required this.name,
    required this.address,
    required this.rssi,
    this.metadata = const {},
  });
}

abstract class DeviceScanner {
  Stream<List<DeviceDiscovery>> get onDiscoveredDevices;
  bool get isScanning;
  Future<void> startScan();
  Future<void> stopScan();
}

abstract class DevicePairing {
  Future<bool> pair(String deviceId);
  Future<bool> unpair(String deviceId);
  Future<bool> isPaired(String deviceId);
}

abstract class DeviceAuthentication {
  Future<bool> authenticate(String deviceId, Map<String, dynamic> credentials);
  Future<bool> isAuthenticated(String deviceId);
}
