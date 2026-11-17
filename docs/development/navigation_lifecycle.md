# Navigation & Application Lifecycle Architecture

## Navigation Abstractions
To avoid coupling to a third-party framework (like `go_router` or `auto_route`), ClaudeWatch uses a clean, contract-driven interface model:
- `NavigationService`: Core contract managing pushing/popping routes.
- `AppRouterAdapter`: Concrete implementation of `AppRouter` (defined in core) that adapts `NavigationService`.

## Route Registry
All routes are declared in [route_registry.dart](file:///c:/Projects/Software%20Projects/ClaudeWatch/lib/app/navigation/route_registry.dart):
- Centralizes path definitions (e.g. `/splash`, `/dashboard`).
- Attaches `RouteMetadata` specifying features, initialization status, title, and ownership.

## Route Guards Chain
Guards implement `RouteGuard` and evaluate asynchronously in a sequential chain:
1. `InitializationGuard`: Asserts system initialization is complete.
2. `FeatureFlagGuard`: Inspects feature toggles to prevent navigation to inactive features.
3. `AuthenticationGuard`: Validates session credentials (future-proofing).

## Application Lifecycle Flow
The `AppLifecycleManager` enforces a strict state transition machine during app launch and runtime:

```text
ProcessStarted → Bootstrap → DependencyRegistration → ConfigurationLoaded 
      ↓
NavigationReady → UIReady → Running ⇄ Background ⇄ Foreground → Shutdown
```

Transition violations throw `StateError` to prevent out-of-order execution during startup.

## Deep-Linking & Widget-Entry
- **Deep-linking**: Incoming scheme URLs trigger the `NavigationService` navigation paths directly.
- **Widget-entry**: The app adapts native incoming Android intents to push designated paths via the route registry.
