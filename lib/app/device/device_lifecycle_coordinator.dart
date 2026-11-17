import 'dart:async';
import 'package:claudewatch/core/device/device_lifecycle.dart';

class DeviceLifecycleCoordinator {
  final DeviceLifecycle _lifecycle = DeviceLifecycle();
  final StreamController<DeviceLifecycleState> _controller =
      StreamController<DeviceLifecycleState>.broadcast();

  DeviceLifecycleState get state => _lifecycle.state;

  Stream<DeviceLifecycleState> get onStateChanged => _controller.stream;

  void transitionTo(DeviceLifecycleState newState) {
    _lifecycle.transitionTo(newState);
    _controller.add(newState);
  }

  void dispose() {
    if (state != DeviceLifecycleState.disposed) {
      transitionTo(DeviceLifecycleState.disposed);
    }
    _controller.close();
  }
}
