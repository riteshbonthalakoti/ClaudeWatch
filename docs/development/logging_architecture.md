# Logging & Diagnostics Architecture

## Overview
The logging and diagnostics architecture provides a centralized, framework-independent mechanism for tracking application state, errors, and performance. All layers of the application must use these abstractions rather than calling `print()` or `developer.log()` directly.

## Architecture

### Logger Facade
The `Logger` is the primary entry point for features. It exposes typed methods like `info()`, `debug()`, `error()`, and `critical()`. It is responsible for wrapping these calls into `LogEntry` objects and passing them to the active sinks.

### Log Categories & Levels
Logs are categorized by `LogCategory` (e.g., Application, Bootstrap, UI, State) and assigned a `LogLevel` (Trace, Debug, Info, Warning, Error, Critical). This allows for fine-grained filtering.

### Sinks, Formatters, and Filters
- **LogSink**: Determines *where* logs go (e.g., Console, Memory, File).
- **LogFilter**: Attached to a sink, determines *if* the sink should process a specific `LogEntry`.
- **LogFormatter**: Determines *how* the log is formatted as text for the sink.

### Observers
`LoggingObserver` allows other systems (e.g., Analytics, Crash Reporting in the future) to tap into the logging stream when logs are created, written, or filtered.

### Diagnostics
The `DiagnosticsProvider` aggregates state from various `DiagnosticsCollector` instances to produce a `DiagnosticsSnapshot`. This snapshot captures things like current memory placeholder, startup duration, and application state, which can be attached to critical error logs or crash reports later.

## Flow
1. Feature code calls `logger.info("Message")`.
2. `AppLoggerImpl` wraps it in a `LogEntry`.
3. `AppLoggerImpl` notifies observers that a log was created.
4. `AppLoggerImpl` iterates through active sinks configured in `LoggingConfiguration`.
5. For each sink, it checks the sink's filters.
6. If filters pass, the sink's formatter converts the entry to text, and it's written.
7. Observers are notified of the successful write or filter rejection.

## Extensibility
In the future, new sinks (e.g., `CrashlyticsLogSink`, `FileLogSink`) can be created and added to the `LoggingConfiguration` without modifying any feature code. 
