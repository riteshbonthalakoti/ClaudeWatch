/// Defines the type of a feature flag value.
enum FeatureFlagType { boolean, string, integer, enumeration }

/// A strongly-typed definition of a feature flag.
class FeatureFlag<T> {
  final String key;
  final FeatureFlagType type;
  final T defaultValue;

  const FeatureFlag({
    required this.key,
    required this.type,
    required this.defaultValue,
  });

  /// Boolean flag definition.
  static FeatureFlag<bool> boolean(String key, {bool defaultValue = false}) {
    return FeatureFlag<bool>(
      key: key,
      type: FeatureFlagType.boolean,
      defaultValue: defaultValue,
    );
  }

  /// String flag definition.
  static FeatureFlag<String> string(String key, {String defaultValue = ''}) {
    return FeatureFlag<String>(
      key: key,
      type: FeatureFlagType.string,
      defaultValue: defaultValue,
    );
  }

  /// Integer flag definition.
  static FeatureFlag<int> integer(String key, {int defaultValue = 0}) {
    return FeatureFlag<int>(
      key: key,
      type: FeatureFlagType.integer,
      defaultValue: defaultValue,
    );
  }
}

/// Interface for evaluating and providing feature flag values.
abstract class FeatureFlagProvider {
  /// Check if a boolean feature is enabled.
  bool isEnabled(FeatureFlag<bool> flag);

  /// Get the strongly typed value of a feature flag.
  T getValue<T>(FeatureFlag<T> flag);
}
