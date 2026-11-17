import 'package:flutter_test/flutter_test.dart';
import 'package:claudewatch/core/modules/module_contracts.dart';
import 'package:claudewatch/core/modules/module_lifecycle.dart';
import 'package:claudewatch/core/modules/module_validator.dart';
import 'package:claudewatch/app/modules/app_module_registry.dart';
import 'package:claudewatch/app/modules/topological_module_loader.dart';
import 'package:claudewatch/app/modules/default_module_validator.dart';
import 'package:claudewatch/app/bootstrap/locator_impl.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/shared/logging/mock_logging.dart';

class TestModule extends ApplicationModule {
  final String _id;
  final List<String> _deps;
  bool isRegistered = false;
  bool isInitialized = false;

  TestModule(this._id, [this._deps = const []]);

  @override
  ModuleMetadata get metadata => ModuleMetadata(
    id: _id,
    name: 'Test \$_id',
    version: '1.0.0',
    dependencies: _deps,
  );

  @override
  void register(ModuleContext context) {
    isRegistered = true;
  }

  @override
  Future<void> initialize(ModuleContext context) async {
    isInitialized = true;
  }
}

void main() {
  group('Module Architecture Tests', () {
    late AppModuleRegistry registry;
    late TopologicalModuleLoader loader;
    late DefaultModuleValidator validator;
    late ModuleContext context;

    setUp(() {
      AppServiceLocator.instance.reset();
      registry = AppModuleRegistry();
      loader = TopologicalModuleLoader();
      validator = DefaultModuleValidator();

      final locator = AppServiceLocator.instance;
      locator.registerSingleton<Logger>(MockLogger());
      context = ModuleContext(locator: locator, logger: locator.get<Logger>());
    });

    test('Valid module graph loads successfully in correct order', () async {
      final moduleA = TestModule('A', []);
      final moduleB = TestModule('B', ['A']);
      final moduleC = TestModule('C', ['B', 'A']);

      // Register out of order
      registry.registerModule(moduleC);
      registry.registerModule(moduleA);
      registry.registerModule(moduleB);

      validator.validate(registry);
      await loader.loadModules(registry, context);

      expect(moduleA.isRegistered, isTrue);
      expect(moduleB.isRegistered, isTrue);
      expect(moduleC.isRegistered, isTrue);

      expect(registry.getModuleState('A'), ModuleLifecycleState.initialized);
      expect(registry.getModuleState('B'), ModuleLifecycleState.initialized);
      expect(registry.getModuleState('C'), ModuleLifecycleState.initialized);
    });

    test('Duplicate registration throws DuplicateModuleException', () {
      final moduleA = TestModule('A', []);
      registry.registerModule(moduleA);

      expect(
        () => registry.registerModule(moduleA),
        throwsA(isA<DuplicateModuleException>()),
      );
    });

    test('Missing dependency throws MissingDependencyException', () {
      final moduleA = TestModule('A', ['MissingDep']);
      registry.registerModule(moduleA);

      expect(
        () => validator.validate(registry),
        throwsA(isA<MissingDependencyException>()),
      );
    });

    test('Circular dependency throws CircularDependencyException', () {
      final moduleA = TestModule('A', ['B']);
      final moduleB = TestModule('B', ['A']);

      registry.registerModule(moduleA);
      registry.registerModule(moduleB);

      expect(
        () => validator.validate(registry),
        throwsA(isA<CircularDependencyException>()),
      );
    });

    test('Lifecycle transitions are validated', () {
      final moduleA = TestModule('A');
      registry.registerModule(moduleA);

      expect(registry.getModuleState('A'), ModuleLifecycleState.registered);

      // Cannot jump straight to initialized
      expect(
        () => registry.updateModuleState('A', ModuleLifecycleState.initialized),
        throwsA(isA<InvalidModuleTransitionException>()),
      );
    });
  });
}
