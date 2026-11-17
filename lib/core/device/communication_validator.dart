import 'package:claudewatch/core/device/device_command_event.dart';
import 'package:claudewatch/core/device/device_metadata.dart';
import 'package:claudewatch/core/device/device_transport.dart';

abstract class CommunicationValidator {
  bool validateCommand(DeviceCommand command);
  bool validatePayload(Map<String, dynamic> payload);
  bool validateCapabilities(DeviceCapabilities capabilities);
  bool validateConnection(DeviceConnection connection);
  bool validateAuthentication(Map<String, dynamic> credentials);
}
