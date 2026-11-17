import 'package:claudewatch/app/bootstrap/bootstrap.dart';
import 'package:claudewatch/app/bootstrap/locator_impl.dart';
import 'package:claudewatch/core/config/configuration.dart';
import 'package:claudewatch/core/config/environment.dart';
import 'package:claudewatch/shared/config/mock_configuration.dart';
import 'package:claudewatch/core/logging/logging_contracts.dart';
import 'package:claudewatch/shared/logging/mock_logging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AppServiceLocator.instance.reset();
  });

  group('Dependency Injection & Bootstrap Tests', () {
    test(
      'Bootstrap completes successfully and registers expected types',
      () async {
        final bootstrapper = AppBootstrapper();
        final locator = await bootstrapper.bootstrap();

        expect(locator.isRegistered<AppConfiguration>(), isTrue);
        expect(locator.isRegistered<Logger>(), isTrue);
        expect(locator.get<AppConfiguration>(), isNotNull);
      },
    );

    test('Registrations occur in the expected deterministic order', () async {
      final bootstrapper = AppBootstrapper();
      await bootstrapper.bootstrap();

      final expectedOrder = [
        'CoreModule',
        'InfrastructureModule',
        'DashboardFeatureModule',
        'HistoryFeatureModule',
        'HomeModule',
        'WidgetsModule',
        'AnalyticsModule',
        'UsageModule',
        'SettingsModule',
        'SearchFeatureModule',
        'PromptLibraryFeatureModule',
        'AIProvidersModule',
      ];
      expect(bootstrapper.registrationOrder, equals(expectedOrder));
    });

    test(
      'Duplicate registrations throw ServiceLocatorException by default',
      () async {
        final locator = AppServiceLocator.instance;
        locator.registerSingleton<Logger>(MockLogger());

        expect(
          () => locator.registerSingleton<Logger>(MockLogger()),
          throwsA(isA<ServiceLocatorException>()),
        );
      },
    );

    test('Test overrides are allowed when explicit flag is active', () async {
      final locator = AppServiceLocator.instance;
      locator.registerSingleton<EnvironmentConfiguration>(
        MockEnvironmentConfiguration(AppEnvironment.development),
      );

      expect(
        locator.get<EnvironmentConfiguration>().currentEnvironment,
        equals(AppEnvironment.development),
      );

      // Enable overrides
      locator.allowOverrides(true);
      locator.registerSingleton<EnvironmentConfiguration>(
        MockEnvironmentConfiguration(AppEnvironment.production),
      );

      expect(
        locator.get<EnvironmentConfiguration>().currentEnvironment,
        equals(AppEnvironment.production),
      );
    });

    test('Missing registrations fail with meaningful diagnostics', () {
      final locator = AppServiceLocator.instance;
      expect(
        () => locator.get<AppConfiguration>(),
        throwsA(
          isA<ServiceLocatorException>().having(
            (e) => e.message,
            'message',
            contains(
              'Missing dependency registration for type: AppConfiguration',
            ),
          ),
        ),
      );
    });
  });
}

// Minimal mock/placeholder setups for testing
