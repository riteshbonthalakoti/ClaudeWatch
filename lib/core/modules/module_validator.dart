import 'module_registry.dart';

/// Validates the module registry for errors such as duplicate registrations, missing dependencies, or circular dependencies.
abstract class ModuleValidator {
  void validate(ModuleRegistry registry);
}

class DuplicateModuleException implements Exception {
  final String moduleId;
  DuplicateModuleException(this.moduleId);
  @override
  String toString() =>
      'DuplicateModuleException: Module \$moduleId is already registered.';
}

class MissingDependencyException implements Exception {
  final String moduleId;
  final String missingDependencyId;
  MissingDependencyException(this.moduleId, this.missingDependencyId);
  @override
  String toString() =>
      'MissingDependencyException: Module \$moduleId depends on \$missingDependencyId which is not registered.';
}

class CircularDependencyException implements Exception {
  final List<String> cycle;
  CircularDependencyException(this.cycle);
  @override
  String toString() =>
      "CircularDependencyException: Circular dependency detected: \${cycle.join(' -> ')}";
}
