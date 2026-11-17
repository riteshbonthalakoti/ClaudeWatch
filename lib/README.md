# ClaudeWatch Application Architecture

This project follows **Clean Architecture** principles structured in a **feature-first** organization layout.

## Directory Structure

```text
lib/
├── app/                  # App initialization, main configurations, global routes, themes
├── core/                 # Central cross-cutting abstractions and contracts
│   ├── analytics/        # Analytics abstractions
│   ├── background/       # Background task management
│   ├── config/           # Environment configuration
│   ├── di/               # Dependency Injection interface
│   ├── error/            # Generic Failure and Exception models
│   ├── logging/          # Diagnostic logging contracts
│   ├── navigation/       # Global navigation contracts
│   ├── notifications/    # Local & remote notification abstractions
│   ├── persistence/      # Local key-value and database contracts
│   ├── provider/         # Dependency registration modules
│   ├── repository/       # Base repository contracts
│   ├── state/            # State management base classes
│   ├── sync/             # Offline-first synchronization abstractions
│   └── widgets/          # Foundational abstract widgets and UI tokens
├── features/             # Business features organized by domain (Clean Architecture per feature)
│   └── dashboard/
│       ├── data/         # Repository implementations, local/remote data sources
│       ├── domain/       # Core entities, use cases, repository contracts
│       └── presentation/ # View layer (Widgets) and Controllers
└── shared/               # Reusable UI widgets and cross-feature helpers
```

## Dependency Direction

```text
      Presentation (Controllers / UI Views)
                   ↓
         Domain (Use Cases / Repository Contracts)
                   ↓
         Core Contracts (Core Interfaces / Abstractions)
                   ↑
         Data Implementations (Repositories / Local Data Sources)
```

- All modules depend inward towards **Core Contracts** and **Domain**.
- **Domain** defines repository interfaces which the **Data** layer implements.
- The **Presentation** layer interacts with the **Domain** (or directly with repositories/use cases via abstraction contracts).
- **Core** contains no concrete feature dependencies.
