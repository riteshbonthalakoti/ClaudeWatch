import 'package:claudewatch/app/lifecycle/lifecycle_manager.dart';
import 'package:claudewatch/app/lifecycle/lifecycle_state.dart';
import 'package:claudewatch/app/navigation/guards.dart';
import 'package:claudewatch/app/navigation/navigation_service.dart';
import 'package:claudewatch/app/navigation/route_registry.dart';
import 'package:flutter_test/flutter_test.dart';

class MockNavigationService implements NavigationService {
  final List<String> navigationHistory = [];

  @override
  Future<T?> navigateTo<T extends Object?>(
    String routePath, {
    Object? arguments,
  }) async {
    navigationHistory.add(routePath);
    return null;
  }

  @override
  Future<T?> replaceWith<T extends Object?, TO extends Object?>(
    String routePath, {
    TO? result,
    Object? arguments,
  }) async {
    navigationHistory.add('REPLACE:$routePath');
    return null;
  }

  @override
  void goBack<T extends Object?>([T? result]) {
    navigationHistory.add('POP');
  }
}

void main() {
  setUp(() {
    AppLifecycleManager.instance.reset();
  });

  group('Navigation & Route Registry Tests', () {
    test('Registry contains all 12 required paths with correct metadata', () {
      final expectedPaths = [
        RouteRegistry.splash,
        RouteRegistry.home,
        RouteRegistry.dashboard,
        RouteRegistry.history,
        RouteRegistry.providers,
        RouteRegistry.analytics,
        RouteRegistry.predictions,
        RouteRegistry.settings,
        RouteRegistry.about,
        RouteRegistry.developer,
        RouteRegistry.error,
        RouteRegistry.notFound,
      ];

      for (final path in expectedPaths) {
        expect(RouteRegistry.routes.containsKey(path), isTrue);
        final route = RouteRegistry.routes[path]!;
        expect(route.metadata.path, equals(path));
      }
    });

    test('Duplicate routes are not present in the registry', () {
      final paths = RouteRegistry.routes.keys.toList();
      final uniquePaths = paths.toSet().toList();
      expect(paths.length, equals(uniquePaths.length));
    });

    test('NavigationService can be mocked correctly', () async {
      final nav = MockNavigationService();
      await nav.navigateTo(RouteRegistry.dashboard);
      await nav.replaceWith(RouteRegistry.settings);
      nav.goBack();

      expect(nav.navigationHistory, [
        RouteRegistry.dashboard,
        'REPLACE:${RouteRegistry.settings}',
        'POP',
      ]);
    });
  });

  group('Application Lifecycle Manager Tests', () {
    test('Starts at processStarted stage', () {
      expect(
        AppLifecycleManager.instance.currentStage,
        AppLifecycleStage.processStarted,
      );
    });

    test('Follows valid sequential transitions successfully', () {
      final manager = AppLifecycleManager.instance;
      manager.transitionTo(AppLifecycleStage.bootstrap);
      manager.transitionTo(AppLifecycleStage.dependencyRegistration);
      manager.transitionTo(AppLifecycleStage.configurationLoaded);
      manager.transitionTo(AppLifecycleStage.navigationReady);
      manager.transitionTo(AppLifecycleStage.uiReady);
      manager.transitionTo(AppLifecycleStage.running);

      expect(manager.currentStage, AppLifecycleStage.running);
    });

    test('Throws StateError on invalid transitions', () {
      final manager = AppLifecycleManager.instance;
      expect(
        () => manager.transitionTo(AppLifecycleStage.running),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Route Guards Execution Tests', () {
    test('Guards resolve sequentially', () async {
      final orderOfExecution = <String>[];
      final guard1 = InitializationGuard(() {
        orderOfExecution.add('guard1');
        return true;
      });
      final guard2 = AuthenticationGuard(() {
        orderOfExecution.add('guard2');
        return true;
      });

      final result1 = await guard1.canNavigate('/test', null);
      final result2 = await guard2.canNavigate('/test', null);

      expect(result1, isTrue);
      expect(result2, isTrue);
      expect(orderOfExecution, equals(['guard1', 'guard2']));
    });
  });
}
