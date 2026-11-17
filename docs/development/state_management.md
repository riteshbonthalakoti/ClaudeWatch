# State Management Architecture

ClaudeWatch uses a framework-independent state management foundation to ensure the core business logic remains completely decoupled from specific state management packages (like Provider, Riverpod, or Bloc).

## Core Contracts

### `ViewState<T>`
A unified representation of UI state. We define exhaustive state variants:
- **`InitialState`**: The default state before any data is loaded.
- **`LoadingState`**: When a process is active. Contains a `LoadingMode` (initial, pullToRefresh, pagination, etc.).
- **`RefreshingState`**: Specific active refreshing phase (alias of loading with previous data).
- **`SuccessState`**: Contains the valid data payload.
- **`EmptyState`**: A valid successful state that represents an empty dataset.
- **`ErrorState`**: Contains a `StateError` denoting failure.

### `StateError`
A standardized error object mapping arbitrary exceptions to defined categories (`recoverable`, `fatal`, `validation`, `unexpected`, `offline`, `timeout`).

### `StateObserver`
A centralized hook for debugging and analytics. It exposes lifecycle hooks for view models and transitions between UI states.

## ViewModel Lifecycle

The `ViewModel<T>` acts as the base coordinator. It enforces strict, deterministic transitions to avoid erratic UI behaviors.

- **Initialization**: Calls `initialize()` upon creation. Emits `InitialState`.
- **Transitions**: Controlled via `emit(ViewState)` internally. Validations prevent illogical jumps (e.g., from `Success` directly to `Initial` without a `reset()` call).
- **Hooks**: Supports application and router lifecycle events (`onStart`, `onResume`, `onPause`, `onBackground`, `onForeground`).

## Integration
Any UI framework or package (e.g. Flutter Bloc, Riverpod) should either:
1. Extend `ViewModel` and bridge `onStateUpdated()` to its package-specific notifier.
2. Observe `ViewModel` via the `StateObserver`.
