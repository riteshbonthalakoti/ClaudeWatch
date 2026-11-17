import 'package:claudewatch/core/config/configuration_loader.dart';
import 'package:claudewatch/core/config/configuration_provider.dart';
import 'package:claudewatch/core/config/environment.dart';
import 'package:claudewatch/app/config/memory_configuration_provider.dart';
import 'package:claudewatch/shared/config/mock_configuration.dart';

class DefaultConfigurationLoader implements ConfigurationLoader {
  @override
  Future<ConfigurationProvider> load(AppEnvironment environment) async {
    // In a real application, this might load from a file or secure storage based on the environment.
    // For this foundation, we populate a memory provider with defaults based on the environment.

    final envConfig = MockEnvironmentConfiguration(environment);

    final config = <String, dynamic>{
      'api_base_url': environment == AppEnvironment.production
          ? 'https://api.claudewatch.com'
          : 'https://dev-api.claudewatch.com',
      'timeout_ms': 5000,
      'is_debug':
          environment == AppEnvironment.development ||
          environment == AppEnvironment.testing,
      'version': 1.0,
    };

    final featureFlags = <String, dynamic>{
      'enable_advanced_metrics': environment == AppEnvironment.development,
      'beta_dashboard_enabled':
          environment == AppEnvironment.development ||
          environment == AppEnvironment.testing,
      'max_retries': 3,
      'theme_override': 'dark', // Example of string flag
    };

    return MemoryConfigurationProvider(
      environment: envConfig,
      config: config,
      featureFlags: featureFlags,
    );
  }
}
