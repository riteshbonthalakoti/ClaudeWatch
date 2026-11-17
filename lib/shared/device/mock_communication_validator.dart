import 'package:claudewatch/core/device/communication_validator.dart';
import 'package:claudewatch/core/device/device_command_event.dart';
import 'package:claudewatch/core/device/device_metadata.dart';
import 'package:claudewatch/core/device/device_transport.dart';

class MockCommunicationValidator implements CommunicationValidator {
  bool shouldValidateCommand = true;
  bool shouldValidatePayload = true;
  bool shouldValidateCapabilities = true;
  bool shouldValidateConnection = true;
  bool shouldValidateAuthentication = true;

  @override
  bool validateCommand(DeviceCommand command) {
    return shouldValidateCommand && command.name.isNotEmpty;
  }

  @override
  bool validatePayload(Map<String, dynamic> payload) {
    return shouldValidatePayload;
  }

  @override
  bool validateCapabilities(DeviceCapabilities capabilities) {
    return shouldValidateCapabilities &&
        capabilities.supportedTransports.isNotEmpty;
  }

  @override
  bool validateConnection(DeviceConnection connection) {
    return shouldValidateConnection;
  }

  @override
  bool validateAuthentication(Map<String, dynamic> credentials) {
    return shouldValidateAuthentication &&
        (credentials.containsKey('pin') || credentials.containsKey('token'));
  }
}
