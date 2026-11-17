import 'dart:async';
import 'package:claudewatch/core/services/service_contracts.dart';
import 'package:claudewatch/core/services/service_lifecycle.dart';

abstract class BaseApplicationService implements ApplicationService {
  final ApplicationServiceLifecycle _lifecycle = ApplicationServiceLifecycle();
  final StreamController<ApplicationServiceLifecycleState> _controller =
      StreamController<ApplicationServiceLifecycleState>.broadcast();

  @override
  ApplicationServiceLifecycleState get state => _lifecycle.state;

  @override
  Stream<ApplicationServiceLifecycleState> get onStateChanged =>
      _controller.stream;

  void transitionTo(ApplicationServiceLifecycleState newState) {
    _lifecycle.transitionTo(newState);
    _controller.add(newState);
  }

  @override
  Future<void> initialize(ApplicationServiceContext context) async {
    transitionTo(ApplicationServiceLifecycleState.initialized);
    transitionTo(ApplicationServiceLifecycleState.ready);
  }

  @override
  Future<void> dispose() async {
    if (state != ApplicationServiceLifecycleState.disposed) {
      transitionTo(ApplicationServiceLifecycleState.disposed);
    }
    await _controller.close();
  }
}
