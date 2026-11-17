/// Defines the lifecycle states a module can be in.
enum ModuleLifecycleState {
  registered,
  loading,
  loaded,
  initializing,
  initialized,
  failed,
  disposed,
}

/// Represents an invalid transition in a module's lifecycle.
class InvalidModuleTransitionException implements Exception {
  final String moduleId;
  final ModuleLifecycleState currentState;
  final ModuleLifecycleState nextState;

  InvalidModuleTransitionException({
    required this.moduleId,
    required this.currentState,
    required this.nextState,
  });

  @override
  String toString() =>
      'InvalidModuleTransitionException(\$moduleId): Cannot transition from \$currentState to \$nextState.';
}
