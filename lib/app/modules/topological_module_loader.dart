import 'package:claudewatch/core/modules/module_contracts.dart';
import 'package:claudewatch/core/modules/module_registry.dart';
import 'package:claudewatch/core/modules/module_loader.dart';
import 'package:claudewatch/core/modules/module_lifecycle.dart';
import 'package:claudewatch/core/modules/module_validator.dart';
import 'package:claudewatch/core/modules/module_observer.dart';

class TopologicalModuleLoader implements ModuleLoader {
  final List<ModuleObserver> observers;

  TopologicalModuleLoader({this.observers = const []});

  @override
  Future<void> loadModules(
    ModuleRegistry registry,
    ModuleContext context,
  ) async {
    final modules = registry.getAllModules();

    // Sort modules topologically
    final sortedModules = _topologicalSort(modules);

    // 1. Register dependencies in DI locator
    for (final module in sortedModules) {
      registry.updateModuleState(
        module.metadata.id,
        ModuleLifecycleState.loading,
      );

      try {
        module.register(context);
        registry.updateModuleState(
          module.metadata.id,
          ModuleLifecycleState.loaded,
        );
      } catch (e, st) {
        registry.updateModuleState(
          module.metadata.id,
          ModuleLifecycleState.failed,
        );
        throw ModuleInitializationException(
          moduleId: module.metadata.id,
          message: 'Failed to register module dependencies.',
          originalError: e,
          stackTrace: st,
        );
      }
    }

    // 2. Initialize modules
    for (final module in sortedModules) {
      registry.updateModuleState(
        module.metadata.id,
        ModuleLifecycleState.initializing,
      );

      final stopwatch = Stopwatch()..start();
      try {
        await module.initialize(context);
        stopwatch.stop();

        registry.updateModuleState(
          module.metadata.id,
          ModuleLifecycleState.initialized,
        );

        for (final observer in observers) {
          observer.onModuleInitialized(module.metadata.id, stopwatch.elapsed);
        }
      } catch (e, st) {
        stopwatch.stop();
        registry.updateModuleState(
          module.metadata.id,
          ModuleLifecycleState.failed,
        );

        final exception = ModuleInitializationException(
          moduleId: module.metadata.id,
          message: 'Failed to initialize module.',
          originalError: e,
          stackTrace: st,
        );

        for (final observer in observers) {
          observer.onModuleInitializationFailed(
            module.metadata.id,
            exception,
            stopwatch.elapsed,
          );
        }

        throw exception;
      }
    }
  }

  List<ApplicationModule> _topologicalSort(List<ApplicationModule> modules) {
    final Map<String, ApplicationModule> moduleMap = {
      for (final m in modules) m.metadata.id: m,
    };

    final Map<String, int> inDegree = {
      for (final m in modules) m.metadata.id: 0,
    };

    final Map<String, List<String>> graph = {
      for (final m in modules) m.metadata.id: [],
    };

    // Build graph and calculate in-degrees
    for (final module in modules) {
      for (final depId in module.metadata.dependencies) {
        if (!moduleMap.containsKey(depId)) {
          throw MissingDependencyException(module.metadata.id, depId);
        }
        graph[depId]!.add(module.metadata.id);
        inDegree[module.metadata.id] = inDegree[module.metadata.id]! + 1;
      }
    }

    // Find all nodes with 0 in-degree
    final List<String> queue = [];
    inDegree.forEach((id, count) {
      if (count == 0) queue.add(id);
    });

    final List<ApplicationModule> sorted = [];
    int visitedCount = 0;

    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      sorted.add(moduleMap[currentId]!);
      visitedCount++;

      for (final neighborId in graph[currentId]!) {
        inDegree[neighborId] = inDegree[neighborId]! - 1;
        if (inDegree[neighborId] == 0) {
          queue.add(neighborId);
        }
      }
    }

    if (visitedCount != modules.length) {
      // Find the nodes that are part of the cycle
      final cycleNodes = inDegree.entries
          .where((e) => e.value > 0)
          .map((e) => e.key)
          .toList();
      throw CircularDependencyException(cycleNodes);
    }

    return sorted;
  }
}
