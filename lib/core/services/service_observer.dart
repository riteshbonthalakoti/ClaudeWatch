import 'package:claudewatch/core/services/service_contracts.dart';
import 'package:claudewatch/core/services/service_result.dart';

abstract class ApplicationServiceObserver {
  void onExecutionStarted(ServiceExecutionContext context);
  void onExecutionFinished(
    ServiceExecutionContext context,
    ApplicationServiceResult<ServiceResponse> result,
  );
  void onExecutionFailed(
    ServiceExecutionContext context,
    Exception exception,
    StackTrace? stackTrace,
  );
  void onExecutionCancelled(ServiceExecutionContext context);
  void onExecutionTimeRecorded(
    String serviceName,
    String action,
    Duration duration,
  );
  void onDiagnosticLogged(
    String serviceName,
    String message, [
    Map<String, dynamic>? details,
  ]);
  void onPerformanceMetricRecorded(
    String metricName,
    double value, [
    Map<String, String>? tags,
  ]);
}
