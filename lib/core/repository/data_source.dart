/// Base contract for all data sources.
abstract interface class DataSource {}

/// A source that stores data locally on the device (e.g., SQLite, Hive).
abstract interface class LocalDataSource implements DataSource {}

/// A source that retrieves data from a network API.
abstract interface class RemoteDataSource implements DataSource {}

/// An in-memory temporary data source.
abstract interface class MemoryDataSource implements DataSource {}

/// A source specifically for caching logic.
abstract interface class CacheDataSource implements DataSource {}

/// A source for communicating with device hardware (e.g., BLE, Sensors).
abstract interface class DeviceDataSource implements DataSource {}

/// A future source for cloud/sync operations.
abstract interface class CloudDataSource implements DataSource {}
