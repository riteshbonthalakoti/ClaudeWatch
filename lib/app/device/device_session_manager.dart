import 'package:claudewatch/core/device/device_lifecycle.dart';
import 'package:claudewatch/core/device/device_transport.dart';

class DeviceSessionImpl implements DeviceSession {
  @override
  final String id;
  @override
  final DeviceConnection connection;
  @override
  final DateTime establishedAt;

  DeviceSessionImpl({
    required this.id,
    required this.connection,
    required this.establishedAt,
  });

  @override
  bool get isActive =>
      connection.state == DeviceLifecycleState.ready ||
      connection.state == DeviceLifecycleState.connected ||
      connection.state == DeviceLifecycleState.authenticating;
}

class DeviceSessionManager {
  DeviceSession? _currentSession;

  DeviceSession? get currentSession => _currentSession;

  void startSession(DeviceSession session) {
    _currentSession = session;
  }

  void endSession() {
    _currentSession = null;
  }
}
