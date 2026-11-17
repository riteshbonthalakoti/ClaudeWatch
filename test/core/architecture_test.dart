import 'package:flutter_test/flutter_test.dart';
import 'mocks.dart';

void main() {
  group('Architecture Core Tests', () {
    test('MockServiceLocator registers and resolves dependency', () {
      final locator = MockServiceLocator();
      final logger = MockLogger();
      locator.registerSingleton<MockLogger>(logger);

      final resolvedLogger = locator.get<MockLogger>();
      expect(resolvedLogger, isNotNull);
      expect(resolvedLogger, equals(logger));
    });

    test('MockLogger logs correct messages', () {
      final logger = MockLogger();
      logger.info('Test Info Message');
      logger.error('Test Error Message');

      expect(logger.logs, contains('INFO: Test Info Message'));
      expect(logger.logs, contains('ERROR: Test Error Message'));
    });
  });
}
