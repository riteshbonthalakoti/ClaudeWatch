class DeviceCapabilities {
  final List<String> supportedTransports;
  final List<String> supportedSensors;
  final bool supportsStreaming;
  final bool supportsAuthentication;
  final bool supportsPairing;
  final Map<String, dynamic> customMetadata;

  const DeviceCapabilities({
    required this.supportedTransports,
    required this.supportedSensors,
    required this.supportsStreaming,
    required this.supportsAuthentication,
    required this.supportsPairing,
    this.customMetadata = const {},
  });

  bool supportsTransport(String transport) {
    return supportedTransports.contains(transport);
  }
}

class DeviceStatus {
  final int batteryLevel;
  final double signalStrength;
  final String firmwareVersion;
  final bool isCharging;
  final int freeMemoryBytes;
  final Duration uptime;

  const DeviceStatus({
    required this.batteryLevel,
    required this.signalStrength,
    required this.firmwareVersion,
    required this.isCharging,
    required this.freeMemoryBytes,
    required this.uptime,
  });
}

enum HealthSeverity { nominal, warning, critical }

class DeviceHealth {
  final bool isHealthy;
  final HealthSeverity severity;
  final Map<String, String> diagnostics;
  final int errorCount;
  final double temperatureCelsius;

  const DeviceHealth({
    required this.isHealthy,
    required this.severity,
    required this.diagnostics,
    required this.errorCount,
    required this.temperatureCelsius,
  });
}
