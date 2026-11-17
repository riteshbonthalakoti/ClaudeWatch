import 'package:claudewatch/core/modules/module_contracts.dart';
import 'package:claudewatch/core/modules/module_lifecycle.dart';
import 'package:claudewatch/core/modules/module_registry.dart';
import 'package:claudewatch/core/modules/module_observer.dart';
import 'package:claudewatch/core/modules/module_validator.dart';

class AppModuleRegistry implements ModuleRegistry {
  final Map<String, ApplicationModule> _modules = {};
  final Map<String, ModuleLifecycleState> _states = {};
  final List<ModuleObserver> observers;

  AppModuleRegistry({this.observers = const []});

  @override
  void registerModule(ApplicationModule module) {
    final id = module.metadata.id;
    if (_modules.containsKey(id)) {
      throw DuplicateModuleException(id);
    }

    _modules[id] = module;
    _states[id] = ModuleLifecycleState.registered;

    for (final observer in observers) {
      observer.onModuleRegistered(module.metadata);
    }
  }

  @override
  List<ApplicationModule> getAllModules() {
    return _modules.values.toList(growable: false);
  }

  @override
  ApplicationModule? getModule(String id) {
    return _modules[id];
  }

  @override
  ModuleLifecycleState getModuleState(String id) {
    if (!_states.containsKey(id)) {
      throw ArgumentError('Module \$id is not registered.');
    }
    return _states[id]!;
  }

  @override
  void updateModuleState(String id, ModuleLifecycleState state) {
    if (!_states.containsKey(id)) {
      throw ArgumentError('Module \$id is not registered.');
    }

    final currentState = _states[id]!;

    if (!_isValidTransition(currentState, state)) {
      throw InvalidModuleTransitionException(
        moduleId: id,
        currentState: currentState,
        nextState: state,
      );
    }

    _states[id] = state;

    for (final observer in observers) {
      observer.onModuleStateChanged(id, currentState, state);
    }
  }

  bool _isValidTransition(
    ModuleLifecycleState current,
    ModuleLifecycleState next,
  ) {
    switch (current) {
      case ModuleLifecycleState.registered:
        return next == ModuleLifecycleState.loading ||
            next == ModuleLifecycleState.disposed;
      case ModuleLifecycleState.loading:
        return next == ModuleLifecycleState.loaded ||
            next == ModuleLifecycleState.failed;
      case ModuleLifecycleState.loaded:
        return next == ModuleLifecycleState.initializing ||
            next == ModuleLifecycleState.disposed;
      case ModuleLifecycleState.initializing:
        return next == ModuleLifecycleState.initialized ||
            next == ModuleLifecycleState.failed;
      case ModuleLifecycleState.initialized:
        return next == ModuleLifecycleState.disposed;
      case ModuleLifecycleState.failed:
        return next == ModuleLifecycleState.disposed;
      case ModuleLifecycleState.disposed:
        return false;
    }
  }
}
