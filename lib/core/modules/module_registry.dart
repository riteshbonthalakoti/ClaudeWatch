import 'module_contracts.dart';
import 'module_lifecycle.dart';

/// Registry holding all known application modules.
abstract class ModuleRegistry {
  /// Registers a module with the registry.
  void registerModule(ApplicationModule module);

  /// Returns all registered modules.
  List<ApplicationModule> getAllModules();

  /// Returns a specific module by its ID.
  ApplicationModule? getModule(String id);

  /// Retrieves the current lifecycle state of a module.
  ModuleLifecycleState getModuleState(String id);

  /// Updates the lifecycle state of a module.
  void updateModuleState(String id, ModuleLifecycleState state);
}
