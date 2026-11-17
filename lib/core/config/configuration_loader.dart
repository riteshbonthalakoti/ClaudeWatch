import 'environment.dart';
import 'configuration_provider.dart';

/// Responsible for initializing and loading configuration data.
abstract class ConfigurationLoader {
  /// Loads configuration for a specific environment and returns a fully populated provider.
  Future<ConfigurationProvider> load(AppEnvironment environment);
}
