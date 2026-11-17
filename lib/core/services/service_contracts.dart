import 'package:claudewatch/core/services/service_lifecycle.dart';
import 'package:claudewatch/core/services/service_result.dart';

class ApplicationServiceContext {
  final String environment;
  final Map<String, dynamic> metadata;

  const ApplicationServiceContext({
    required this.environment,
    this.metadata = const {},
  });
}

class ServiceRequest {
  final String id;
  final String action;
  final Map<String, dynamic> payload;

  const ServiceRequest({
    required this.id,
    required this.action,
    this.payload = const {},
  });
}

class ServiceResponse {
  final String requestId;
  final Map<String, dynamic> data;
  final bool isSuccess;

  const ServiceResponse({
    required this.requestId,
    required this.data,
    required this.isSuccess,
  });
}

class ServiceExecutionContext {
  final ServiceRequest request;
  final ApplicationServiceContext context;
  final DateTime startTime;

  const ServiceExecutionContext({
    required this.request,
    required this.context,
    required this.startTime,
  });
}

abstract class ApplicationService {
  ApplicationServiceLifecycleState get state;
  Stream<ApplicationServiceLifecycleState> get onStateChanged;

  Future<void> initialize(ApplicationServiceContext context);
  Future<ApplicationServiceResult<ServiceResponse>> execute(
    ServiceRequest request,
  );
  Future<void> dispose();
}
