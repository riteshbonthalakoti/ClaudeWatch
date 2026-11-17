/// A snapshot of the application's diagnostic state.
class DiagnosticsSnapshot {
  final DateTime timestamp;
  final String appVersion;
  final String environment;
  final String buildMode;
  final int registeredServicesCount;
  final String currentRoute;
  final String memoryUsagePlaceholder;
  final Duration startupDuration;

  DiagnosticsSnapshot({
    required this.timestamp,
    required this.appVersion,
    required this.environment,
    required this.buildMode,
    required this.registeredServicesCount,
    required this.currentRoute,
    required this.memoryUsagePlaceholder,
    required this.startupDuration,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'appVersion': appVersion,
    'environment': environment,
    'buildMode': buildMode,
    'registeredServicesCount': registeredServicesCount,
    'currentRoute': currentRoute,
    'memoryUsagePlaceholder': memoryUsagePlaceholder,
    'startupDurationMs': startupDuration.inMilliseconds,
  };
}

/// Interface for collecting specific diagnostic metrics.
abstract class DiagnosticsCollector {
  Future<void> collect(Map<String, dynamic> output);
}

/// Interface for generating diagnostic snapshots.
abstract class DiagnosticsProvider {
  Future<DiagnosticsSnapshot> generateSnapshot();
  void registerCollector(DiagnosticsCollector collector);
}
