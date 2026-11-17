# Repository & Data Access Architecture

ClaudeWatch employs a strictly decoupled, framework-agnostic repository architecture. This ensures our feature business logic interacts exclusively with abstract contracts, preventing tight coupling to any specific database (SQLite, Hive, Isar) or networking client (http, dio).

## Repository Result Model
All repository operations must return a `RepositoryResult<T>`. This sealed class guarantees exhaustive pattern matching and prevents unhandled exceptions from crashing the UI layer.

- **`RepositorySuccess<T>`**: Operation succeeded; payload provided.
- **`RepositoryFailure<T>`**: Operation failed; contains a `RepositoryException`.
- **`RepositoryEmpty<T>`**: Operation succeeded but dataset is empty (avoiding null checks).
- **`RepositoryCached<T>`**: Stale or local data served alongside a timestamp.
- **`RepositoryOffline<T>`**: Network unavailable, possibly accompanied by local fallback data.
- **`RepositoryLoading<T>`**: Streamed or prolonged loading states with optional progress.
- **`RepositoryPartialSuccess<T>`**: Multi-item operation completed with some failures.

## Repository Error Model
The `RepositoryException` strictly categorizes errors using `RepositoryErrorType`:
`validation`, `notFound`, `conflict`, `permission`, `offline`, `timeout`, `cancelled`, `unexpected`, `fatal`.

## Data Source Boundaries
Repositories fetch data from `DataSource` abstractions:
- **`LocalDataSource`**: Device storage (DB, KV store).
- **`RemoteDataSource`**: Network APIs.
- **`MemoryDataSource`**: In-memory caching.
- **`DeviceDataSource`**: Hardware APIs (Sensors, BLE).

## Repository Lifecycle
Repositories follow a strict `RepositoryLifecycleState`:
`created -> initialized -> ready <-> synchronizing/refreshing -> disposed`.
The `RepositoryLifecycle` mixin enforces valid transitions.

## Validation and Transactions
- **`RepositoryValidator`**: Standardizes entity, input, and output validation directly at the data boundary.
- **`RepositoryTransaction`**: Ensures atomic operations are respected across layers.
