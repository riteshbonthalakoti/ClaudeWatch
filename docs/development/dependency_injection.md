# Dependency Injection Architecture Guidelines

ClaudeWatch uses a custom, lightweight, production-grade Service Locator framework managed through a single **Composition Root**.

## Registration Flow

All dependencies are registered deterministically during the application bootstrap sequence:

```text
App Entry (main.dart)
      ↓
AppBootstrapper.bootstrap()
      ↓
1. CoreModule (Config, Logger)
2. InfrastructureModule (Router, LocalStorage, Analytics, Notifications, Sync, BG Tasks)
3. FeatureModule (Feature Repositories & Controllers)
      ↓
Validate registrations & return ServiceLocator
```

## Service Lifetime Policies

Dependencies must be registered using one of three lifetimes:

1. **Singleton**:
   - Registered via `registerSingleton<T>(instance)`.
   - The instance is created eagerly and persists for the lifetime of the application.
   - *Use Case*: Cross-cutting services that maintain active streams or sockets, global configurations, or simple immutable constants.

2. **Lazy Singleton**:
   - Registered via `registerLazySingleton<T>(() => instance)`.
   - The instance is created only when first requested and then cached.
   - *Use Case*: Services with expensive initialization processes (e.g. database setup, remote repositories, local storage engines).

3. **Factory**:
   - Registered via `registerFactory<T>(() => instance)`.
   - A fresh instance is created on every resolution request.
   - *Use Case*: Presentation layer Controllers/Blocs, transient UI models, or short-lived stateful containers.

## Constructor Injection Default

To maintain clean, loosely coupled architectures, always use **constructor injection** for classes that require dependencies.

```dart
// CORRECT: Constructor Injection
class DashboardController {
  final DashboardRepository repository;

  DashboardController(this.repository);
}

// INCORRECT: Direct Service Locator resolution
class DashboardController {
  final DashboardRepository repository = AppServiceLocator.instance.get<DashboardRepository>();
}
```
*Never reference the ServiceLocator/Composition Root directly inside feature modules or presentation code.*

## Testing & Overrides Strategy

During unit tests, standard production registrations can be safely overridden.

```dart
final locator = AppServiceLocator.instance;
locator.allowOverrides(true);

// Register a mock implementation of a service
locator.registerSingleton<AppLogger>(MockLogger());
```
Always call `AppServiceLocator.instance.reset()` between test executions to ensure isolation.
