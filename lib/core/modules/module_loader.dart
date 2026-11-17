import 'module_contracts.dart';
import 'module_registry.dart';

/// Orchestrates the initialization of modules, respecting their dependencies.
abstract class ModuleLoader {
  /// Initializes all modules in the registry in topological order.
  Future<void> loadModules(ModuleRegistry registry, ModuleContext context);
}
