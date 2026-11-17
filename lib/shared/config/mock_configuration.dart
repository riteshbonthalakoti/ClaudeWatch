import 'package:claudewatch/core/config/configuration.dart';
import 'package:claudewatch/core/config/configuration_provider.dart';
import 'package:claudewatch/core/config/environment.dart';
import 'package:claudewatch/core/config/feature_flags.dart';

class MockEnvironmentConfiguration implements EnvironmentConfiguration {
  @override
  final AppEnvironment currentEnvironment;

  MockEnvironmentConfiguration(this.currentEnvironment);

  @override
  String get environmentName => currentEnvironment.name;

  @override
  bool get isDevelopment => currentEnvironment == AppEnvironment.development;

  @override
  bool get isProduction => currentEnvironment == AppEnvironment.production;

  @override
  bool get isStaging => currentEnvironment == AppEnvironment.staging;

  @override
  bool get isTesting => currentEnvironment == AppEnvironment.testing;
}

class AppConfigurationImpl implements AppConfiguration {
  final ConfigurationProvider _provider;
  final FeatureFlagProvider _featureFlagProvider;

  AppConfigurationImpl({
    required ConfigurationProvider provider,
    required FeatureFlagProvider featureFlagProvider,
  }) : _provider = provider,
       _featureFlagProvider = featureFlagProvider;

  @override
  EnvironmentConfiguration get environment => _provider.environment;

  @override
  bool getBool(String key) {
    final value = _provider.getValue(key);
    if (value is bool) return value;
    throw StateError('Configuration key "\$key" is not a boolean.');
  }

  @override
  double getDouble(String key) {
    final value = _provider.getValue(key);
    if (value is double) return value;
    if (value is int) return value.toDouble();
    throw StateError('Configuration key "\$key" is not a double.');
  }

  @override
  int getInt(String key) {
    final value = _provider.getValue(key);
    if (value is int) return value;
    throw StateError('Configuration key "\$key" is not an integer.');
  }

  @override
  String getString(String key) {
    final value = _provider.getValue(key);
    if (value is String) return value;
    throw StateError('Configuration key "\$key" is not a string.');
  }

  @override
  T getFeatureValue<T>(FeatureFlag flag) {
    return _featureFlagProvider.getValue<T>(flag as FeatureFlag<T>);
  }

  @override
  bool isFeatureEnabled(FeatureFlag flag) {
    if (flag.type != FeatureFlagType.boolean) {
      throw StateError(
        'isFeatureEnabled called on non-boolean flag "\${flag.key}".',
      );
    }
    return _featureFlagProvider.isEnabled(flag as FeatureFlag<bool>);
  }
}

class FeatureFlagProviderImpl implements FeatureFlagProvider {
  final ConfigurationProvider _provider;

  FeatureFlagProviderImpl(this._provider);

  @override
  T getValue<T>(FeatureFlag<T> flag) {
    try {
      final value = _provider.getFeatureFlagValue(flag.key);
      if (value is T) return value;
      throw StateError(
        'Type mismatch for flag "\${flag.key}". Expected \$T, got \${value.runtimeType}.',
      );
    } catch (e) {
      // Fallback to default if not found or on error
      if (e is StateError && e.message.contains('not found')) {
        return flag.defaultValue;
      }
      rethrow;
    }
  }

  @override
  bool isEnabled(FeatureFlag<bool> flag) {
    return getValue<bool>(flag);
  }
}
