import 'package:claudewatch/core/config/configuration_provider.dart';
import 'package:claudewatch/core/config/environment.dart';

class MemoryConfigurationProvider implements ConfigurationProvider {
  final Map<String, dynamic> _config;
  final Map<String, dynamic> _featureFlags;
  @override
  final EnvironmentConfiguration environment;

  MemoryConfigurationProvider({
    required this.environment,
    Map<String, dynamic> config = const {},
    Map<String, dynamic> featureFlags = const {},
  }) : _config = Map.from(config),
       _featureFlags = Map.from(featureFlags);

  @override
  dynamic getValue(String key) {
    if (!_config.containsKey(key)) {
      throw StateError('Configuration key "\$key" not found.');
    }
    return _config[key];
  }

  @override
  dynamic getFeatureFlagValue(String key) {
    if (!_featureFlags.containsKey(key)) {
      throw StateError('Feature flag "\$key" not found.');
    }
    return _featureFlags[key];
  }

  /// Exposes a way to update config at runtime for testing purposes.
  void setConfig(String key, dynamic value) {
    _config[key] = value;
  }

  /// Exposes a way to update feature flags at runtime for testing purposes.
  void setFeatureFlag(String key, dynamic value) {
    _featureFlags[key] = value;
  }
}
