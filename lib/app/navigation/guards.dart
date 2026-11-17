import 'package:claudewatch/app/navigation/navigation_service.dart';

class InitializationGuard extends RouteGuard {
  final bool Function() isInitialized;
  InitializationGuard(this.isInitialized);

  @override
  Future<bool> canNavigate(String path, Object? arguments) async {
    return isInitialized();
  }
}

class FeatureFlagGuard extends RouteGuard {
  final bool Function(String feature) isFeatureEnabled;
  FeatureFlagGuard(this.isFeatureEnabled);

  @override
  Future<bool> canNavigate(String path, Object? arguments) async {
    // Check feature toggle associated with route
    return isFeatureEnabled(path);
  }
}

class AuthenticationGuard extends RouteGuard {
  final bool Function() isAuthenticated;
  AuthenticationGuard(this.isAuthenticated);

  @override
  Future<bool> canNavigate(String path, Object? arguments) async {
    return isAuthenticated();
  }
}
