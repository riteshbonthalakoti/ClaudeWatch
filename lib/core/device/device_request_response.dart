enum DeviceResponseStatus {
  success,
  failure,
  timeout,
  cancelled,
  offline,
  partial,
  streamingReady,
}

class DeviceRequest {
  final String id;
  final String path;
  final Map<String, dynamic> payload;
  final Duration timeout;
  final DateTime timestamp;

  const DeviceRequest({
    required this.id,
    required this.path,
    this.payload = const {},
    this.timeout = const Duration(seconds: 30),
    required this.timestamp,
  });
}

class DeviceResponse {
  final String requestId;
  final DeviceResponseStatus status;
  final Map<String, dynamic> payload;
  final String? errorMessage;
  final DateTime timestamp;

  const DeviceResponse({
    required this.requestId,
    required this.status,
    this.payload = const {},
    this.errorMessage,
    required this.timestamp,
  });
}
