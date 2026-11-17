import 'package:claudewatch/app/navigation/navigation_service.dart';

class RouteRegistry {
  RouteRegistry._();

  static const String splash = '/splash';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String providers = '/providers';
  static const String analytics = '/analytics';
  static const String predictions = '/predictions';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String developer = '/developer';
  static const String error = '/error';
  static const String notFound = '/not-found';

  static final Map<String, RouteDefinition> routes = {
    splash: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'splash',
        path: splash,
        title: 'Splash',
        requiresInitialization: false,
        featureOwnership: 'core',
      ),
      guards: [],
    ),
    home: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'home',
        path: home,
        title: 'Home',
        requiresInitialization: true,
        featureOwnership: 'core',
      ),
      guards: [],
    ),
    dashboard: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'dashboard',
        path: dashboard,
        title: 'Dashboard',
        requiresInitialization: true,
        featureOwnership: 'dashboard',
      ),
      guards: [],
    ),
    history: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'history',
        path: history,
        title: 'AI Usage History',
        requiresInitialization: true,
        featureOwnership: 'history',
      ),
      guards: [],
    ),
    providers: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'providers',
        path: providers,
        title: 'AI Providers',
        requiresInitialization: true,
        featureOwnership: 'providers',
      ),
      guards: [],
    ),
    analytics: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'analytics',
        path: analytics,
        title: 'Analytics',
        requiresInitialization: true,
        featureOwnership: 'analytics',
      ),
      guards: [],
    ),
    predictions: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'predictions',
        path: predictions,
        title: 'Predictions',
        requiresInitialization: true,
        featureOwnership: 'predictions',
      ),
      guards: [],
    ),
    settings: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'settings',
        path: settings,
        title: 'Settings',
        requiresInitialization: false,
        featureOwnership: 'settings',
      ),
      guards: [],
    ),
    about: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'about',
        path: about,
        title: 'About',
        requiresInitialization: false,
        featureOwnership: 'settings',
      ),
      guards: [],
    ),
    developer: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'developer',
        path: developer,
        title: 'Developer Options',
        requiresInitialization: false,
        featureOwnership: 'developer',
      ),
      guards: [],
    ),
    error: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'error',
        path: error,
        title: 'Error',
        requiresInitialization: false,
        featureOwnership: 'core',
      ),
      guards: [],
    ),
    notFound: RouteDefinition(
      metadata: const RouteMetadata(
        routeId: 'notFound',
        path: notFound,
        title: 'Not Found',
        requiresInitialization: false,
        featureOwnership: 'core',
      ),
      guards: [],
    ),
  };
}
