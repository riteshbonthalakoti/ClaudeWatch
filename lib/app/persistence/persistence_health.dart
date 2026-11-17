/// Reporting models for persistence health.
enum PersistenceHealthState {
  available,
  busy,
  locked,
  corrupted,
  recovering,
  healthy,
  unhealthy,
}

/// Represents a health snapshot.
class PersistenceHealth {
  final PersistenceHealthState state;
  final String? diagnosis;
  final DateTime timestamp;

  const PersistenceHealth({
    required this.state,
    this.diagnosis,
    required this.timestamp,
  });
}

/// Contract for objects that can report persistence health.
abstract interface class HealthReporter {
  Future<PersistenceHealth> checkHealth();
}
