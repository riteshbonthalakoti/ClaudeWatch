import 'module_contracts.dart';
import 'module_lifecycle.dart';

/// Observer for monitoring the lifecycle of application modules.
abstract class ModuleObserver {
  void onModuleRegistered(ModuleMetadata metadata);
  void onModuleStateChanged(
    String moduleId,
    ModuleLifecycleState oldState,
    ModuleLifecycleState newState,
  );
  void onModuleInitialized(String moduleId, Duration duration);
  void onModuleInitializationFailed(
    String moduleId,
    ModuleInitializationException error,
    Duration duration,
  );
}
