# Module Registration & Composition Root Architecture

## Overview
The application architecture divides responsibilities into autonomous **Modules**. A module can represent a slice of infrastructure (e.g., `CoreModule`), a collection of services, or an entire feature (e.g., `DashboardFeatureModule`).

This architecture completely removes manual, rigid dependency ordering in `AppBootstrapper` and replaces it with dynamic, topological initialization.

## Key Abstractions

### `ApplicationModule` & `FeatureModule`
Every module must extend `ApplicationModule` or `FeatureModule`. They define:
- `ModuleMetadata`: Unique ID, version, and dependencies.
- `register(ModuleContext)`: Hook to register dependencies in the central `ServiceLocator`.
- `initialize(ModuleContext)`: Asynchronous hook to start/load data or connect to services after registration.

### `ModuleRegistry`
Acts as the central repository for all discovered modules. Prevents duplicate registrations.

### `ModuleLoader`
Reads the `ModuleRegistry` and sorts the modules based on their stated dependencies.
Uses topological sort. If `feature.b` depends on `feature.a`, the loader guarantees `feature.a` is registered and initialized first.

### `ModuleValidator`
Ensures graph integrity before any registrations occur. Protects against:
- Duplicate Modules
- Missing Dependencies
- Circular Dependencies

## Onboarding Future Features

To onboard a new feature:

1. Create a class extending `FeatureModule`.
2. Define its `ModuleMetadata`, listing dependencies by their string IDs.
```dart
class SettingsModule extends FeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
        id: 'feature.settings',
        name: 'Settings',
        version: '1.0.0',
        dependencies: ['core.infrastructure'],
      );

  @override
  void register(ModuleContext context) {
    context.locator.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());
  }
}
```
3. Add the `SettingsModule()` instantiation to the `_modules` list within `AppBootstrapper`.

No further wiring is needed. The `ModuleLoader` will automatically determine the precise point in the boot sequence to load and initialize `SettingsModule`.
