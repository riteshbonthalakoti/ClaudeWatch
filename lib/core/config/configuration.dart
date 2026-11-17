import 'environment.dart';
import 'feature_flags.dart';

/// Centralized configuration access for the application.
abstract class AppConfiguration {
  /// The current environment details.
  EnvironmentConfiguration get environment;

  /// Gets a string value. Throws if not found or not a string.
  String getString(String key);

  /// Gets an integer value. Throws if not found or not an integer.
  int getInt(String key);

  /// Gets a boolean value. Throws if not found or not a boolean.
  bool getBool(String key);

  /// Gets a double value. Throws if not found or not a double.
  double getDouble(String key);

  /// Checks if a feature flag is enabled.
  bool isFeatureEnabled(FeatureFlag flag);

  /// Gets the strongly typed value of a feature flag.
  T getFeatureValue<T>(FeatureFlag flag);
}
