import 'environment.dart';

/// Provides raw configuration data to the application.
abstract class ConfigurationProvider {
  /// The current environment configuration.
  EnvironmentConfiguration get environment;

  /// Gets a value from the configuration source.
  dynamic getValue(String key);

  /// Get a feature flag value from the configuration source.
  dynamic getFeatureFlagValue(String key);
}
