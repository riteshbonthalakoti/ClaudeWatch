import 'package:claudewatch/core/di/service_locator.dart';

abstract class ServiceProvider {
  void register(ServiceLocator locator);
}
