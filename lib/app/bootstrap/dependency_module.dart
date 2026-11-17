import 'package:claudewatch/core/di/service_locator.dart';

abstract class DependencyModule {
  void register(ServiceLocator locator);
}
