import 'package:flutter_test/flutter_test.dart';
import 'package:claudewatch/core/config/configuration.dart';
import 'package:claudewatch/core/config/configuration_provider.dart';
import 'package:claudewatch/core/config/environment.dart';
import 'package:claudewatch/core/config/feature_flags.dart';
import 'package:claudewatch/app/config/memory_configuration_provider.dart';
import 'package:claudewatch/shared/config/mock_configuration.dart';
import 'package:claudewatch/app/bootstrap/bootstrap.dart';

void main() {
  group('Configuration & Environment Foundation', () {
    test('MemoryConfigurationProvider retrieves correct values', () {
      final env = MockEnvironmentConfiguration(AppEnvironment.development);
      final provider = MemoryConfigurationProvider(
        environment: env,
        config: {'api_url': 'test', 'timeout': 100},
        featureFlags: {'enable_beta': true},
      );

      expect(
        provider.environment.currentEnvironment,
        AppEnvironment.development,
      );
      expect(provider.getValue('api_url'), 'test');
      expect(provider.getValue('timeout'), 100);
      expect(provider.getFeatureFlagValue('enable_beta'), true);

      expect(() => provider.getValue('missing'), throwsStateError);
      expect(
        () => provider.getFeatureFlagValue('missing_flag'),
        throwsStateError,
      );
    });

    test('AppConfigurationImpl correctly types values', () {
      final env = MockEnvironmentConfiguration(AppEnvironment.development);
      final provider = MemoryConfigurationProvider(
        environment: env,
        config: {
          'string_val': 'hello',
          'int_val': 42,
          'bool_val': true,
          'double_val': 3.14,
          'int_as_double': 10,
        },
        featureFlags: {},
      );
      final featureProvider = FeatureFlagProviderImpl(provider);

      final appConfig = AppConfigurationImpl(
        provider: provider,
        featureFlagProvider: featureProvider,
      );

      expect(appConfig.getString('string_val'), 'hello');
      expect(appConfig.getInt('int_val'), 42);
      expect(appConfig.getBool('bool_val'), true);
      expect(appConfig.getDouble('double_val'), 3.14);
      expect(appConfig.getDouble('int_as_double'), 10.0);

      expect(() => appConfig.getString('int_val'), throwsStateError);
    });

    test('FeatureFlagProviderImpl retrieves correct typed values', () {
      final env = MockEnvironmentConfiguration(AppEnvironment.development);
      final provider = MemoryConfigurationProvider(
        environment: env,
        config: {},
        featureFlags: {'beta': true, 'limit': 5},
      );
      final featureProvider = FeatureFlagProviderImpl(provider);

      final betaFlag = FeatureFlag.boolean('beta');
      final limitFlag = FeatureFlag.integer('limit');
      final missingFlag = FeatureFlag.string(
        'missing',
        defaultValue: 'default',
      );

      expect(featureProvider.isEnabled(betaFlag), true);
      expect(featureProvider.getValue(limitFlag), 5);
      expect(featureProvider.getValue(missingFlag), 'default');
    });

    test('Bootstrapper registers core configuration properly', () async {
      final bootstrapper = AppBootstrapper();
      final locator = await bootstrapper.bootstrap();

      expect(locator.isRegistered<AppConfiguration>(), true);
      expect(locator.isRegistered<ConfigurationProvider>(), true);
      expect(locator.isRegistered<FeatureFlagProvider>(), true);
      expect(locator.isRegistered<EnvironmentConfiguration>(), true);
    });
  });
}
