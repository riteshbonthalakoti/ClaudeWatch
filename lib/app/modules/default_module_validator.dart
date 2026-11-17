import 'package:claudewatch/core/modules/module_registry.dart';
import 'package:claudewatch/core/modules/module_validator.dart';

class DefaultModuleValidator implements ModuleValidator {
  @override
  void validate(ModuleRegistry registry) {
    final modules = registry.getAllModules();

    // Duplicate detection is already handled by registry during registration,
    // but we can double check.
    final ids = <String>{};
    for (final module in modules) {
      if (ids.contains(module.metadata.id)) {
        throw DuplicateModuleException(module.metadata.id);
      }
      ids.add(module.metadata.id);
    }

    // Missing dependencies
    for (final module in modules) {
      for (final dep in module.metadata.dependencies) {
        if (!ids.contains(dep)) {
          throw MissingDependencyException(module.metadata.id, dep);
        }
      }
    }

    // Circular dependencies can be detected by running a dry-run topological sort
    // The TopologicalModuleLoader does this sorting, so we can reuse its logic here or
    // simply let the loader throw CircularDependencyException.
    // For separation of concerns, we can implement a basic cycle detector here.
    _detectCycles(modules);
  }

  void _detectCycles(List<dynamic> modules) {
    // Use dynamic casting or just let the loader's actual sort throw it.
    // The simplest way to validate is just to do the topological sort on the list.
    // Since _topologicalSort is private in TopologicalModuleLoader, let's implement a quick cycle check.

    final graph = <String, List<String>>{};
    for (final m in modules) {
      graph[m.metadata.id] = m.metadata.dependencies;
    }

    final visited = <String>{};
    final recursionStack = <String>{};

    bool isCyclic(String node) {
      if (!visited.contains(node)) {
        visited.add(node);
        recursionStack.add(node);

        for (final neighbor in graph[node] ?? []) {
          if (!visited.contains(neighbor) && isCyclic(neighbor)) {
            return true;
          } else if (recursionStack.contains(neighbor)) {
            return true;
          }
        }
      }
      recursionStack.remove(node);
      return false;
    }

    for (final node in graph.keys) {
      if (isCyclic(node)) {
        // Find nodes involved in cycle for the exception
        throw CircularDependencyException(recursionStack.toList());
      }
    }
  }
}
