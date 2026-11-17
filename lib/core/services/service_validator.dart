import 'package:claudewatch/core/services/service_contracts.dart';

abstract class ApplicationServiceValidator {
  bool validateInput(Map<String, dynamic> input);
  bool validateRequest(ServiceRequest request);
  bool validateResponse(ServiceResponse response);
  bool validateExecution(ServiceExecutionContext context);
}
