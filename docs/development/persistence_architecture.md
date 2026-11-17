# Persistence Architecture Foundation

ClaudeWatch utilizes a tightly controlled Persistence Architecture layer that strictly separates feature repositories from the underlying database technologies.

## Framework Independence
No feature, presentation layer, or domain logic interacts directly with SQLite, Hive, Isar, or Drift. All persistence operations are routed through `PersistenceEngine` and its `DatabaseProvider`.

## Core Abstractions

### `PersistenceEngine`
The central manager of database connections, handling initialization (`PersistenceConfiguration`) and lifecycle (`DatabaseConnection`, `DatabaseSession`).

### Migration Framework
- **`MigrationProvider`**: Manages a queue of pending and historical migrations.
- **`Migration`**: Enforces strict `up()` / `down()` migration paths along with `checksum` validation to ensure schema integrity across updates.

### Transactions
- **`DatabaseTransaction`**: Wraps native transactions, providing unified hooks for `begin`, `commit`, `rollback`, and `cancel`.

### Health & Validation
- **`PersistenceHealth`**: Reports database vitality (`available`, `locked`, `corrupted`, `recovering`). This ensures the app can elegantly degrade into offline mode or trigger recovery workflows if a local database corruption occurs.
- **`PersistenceValidator`**: Intercepts configurations, schemas, migrations, and connections for rigorous integrity checking.

## Lifecycle Enforcement
Databases strictly progress through deterministic states:
`created -> opening -> opened -> migrating -> ready -> closing -> closed`
Any deviation triggers an immediate exception, safeguarding data against race conditions during startup.
