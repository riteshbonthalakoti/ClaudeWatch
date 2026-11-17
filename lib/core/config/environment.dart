/// Defines the environments the application can run in.
enum AppEnvironment { development, testing, staging, production }

/// Exposes environment-specific details.
abstract class EnvironmentConfiguration {
  AppEnvironment get currentEnvironment;
  String get environmentName;
  bool get isDevelopment;
  bool get isProduction;
  bool get isTesting;
  bool get isStaging;
}
