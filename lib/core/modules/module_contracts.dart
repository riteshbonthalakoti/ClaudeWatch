import 'package:claudewatch/core/di/service_locator.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';

/// Metadata identifying a module and its dependencies.
class ModuleMetadata {
  final String id;
  final String name;
  final String version;
  final List<String> dependencies; // IDs of modules this module depends on

  const ModuleMetadata({
    required this.id,
    required this.name,
    required this.version,
    this.dependencies = const [],
  });
}

/// A context provided to a module during registration and initialization.
class ModuleContext {
  final ServiceLocator locator;
  final Logger logger;

  ModuleContext({required this.locator, required this.logger});
}

/// The base interface for any module in the application.
abstract class ApplicationModule {
  ModuleMetadata get metadata;

  /// Registers dependencies into the service locator.
  void register(ModuleContext context);

  /// Initializes the module (e.g., establishing connections, preparing data).
  Future<void> initialize(ModuleContext context) async {}

  /// Disposes of the module's resources.
  Future<void> dispose(ModuleContext context) async {}
}

/// A specialized module that represents a distinct feature area.
abstract class FeatureModule extends ApplicationModule {
  // Feature modules might expose additional route/navigation mappings in the future.
}

/// The result of an initialization attempt.
class ModuleInitializationResult {
  final bool success;
  final Duration duration;
  final ModuleInitializationException? error;

  ModuleInitializationResult.success({required this.duration})
    : success = true,
      error = null;

  ModuleInitializationResult.failure({
    required this.error,
    required this.duration,
  }) : success = false;
}

/// Exception thrown during module initialization.
class ModuleInitializationException implements Exception {
  final String moduleId;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  ModuleInitializationException({
    required this.moduleId,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'ModuleInitializationException(\$moduleId): \$message';
}
