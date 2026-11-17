enum DeviceEventType {
  connected,
  disconnected,
  reconnected,
  commandReceived,
  commandSent,
  error,
  healthChanged,
  capabilityChanged,
}

class DeviceEvent {
  final DeviceEventType type;
  final String deviceId;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const DeviceEvent({
    required this.type,
    required this.deviceId,
    required this.timestamp,
    this.data = const {},
  });
}

class DeviceCommand {
  final String id;
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  const DeviceCommand({
    required this.id,
    required this.name,
    this.parameters = const {},
    required this.timestamp,
  });
}
