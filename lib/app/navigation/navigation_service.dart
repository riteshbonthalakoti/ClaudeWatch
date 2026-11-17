abstract class NavigationService {
  Future<T?> navigateTo<T extends Object?>(
    String routePath, {
    Object? arguments,
  });
  Future<T?> replaceWith<T extends Object?, TO extends Object?>(
    String routePath, {
    TO? result,
    Object? arguments,
  });
  void goBack<T extends Object?>([T? result]);
}

class RouteMetadata {
  final String routeId;
  final String path;
  final String title;
  final bool requiresInitialization;
  final String featureOwnership;

  const RouteMetadata({
    required this.routeId,
    required this.path,
    required this.title,
    required this.requiresInitialization,
    required this.featureOwnership,
  });
}

class RouteDefinition {
  final RouteMetadata metadata;
  final List<RouteGuard> guards;

  const RouteDefinition({required this.metadata, required this.guards});
}

abstract class RouteGuard {
  Future<bool> canNavigate(String path, Object? arguments);
}

abstract class AppNavigationObserver {
  void didPush(String path);
  void didPop();
}
