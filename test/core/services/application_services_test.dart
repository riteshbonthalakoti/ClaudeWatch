import 'package:claudewatch/app/bootstrap/bootstrap.dart';
import 'package:claudewatch/app/bootstrap/locator_impl.dart';

import 'package:claudewatch/app/services/base_service.dart';
import 'package:claudewatch/core/services/service_lifecycle.dart';
import 'package:claudewatch/core/services/service_result.dart';
import 'package:claudewatch/core/services/service_contracts.dart';
import 'package:claudewatch/core/services/service_observer.dart';
import 'package:claudewatch/core/services/service_validator.dart';
import 'package:claudewatch/shared/services/usage_service.dart';
import 'package:claudewatch/shared/services/conversation_service.dart';
import 'package:claudewatch/shared/services/analytics_service.dart';
import 'package:claudewatch/shared/services/settings_service.dart';
import 'package:claudewatch/shared/services/widget_service.dart';
import 'package:claudewatch/shared/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

class TestService extends BaseApplicationService {
  @override
  Future<ApplicationServiceResult<ServiceResponse>> execute(
    ServiceRequest request,
  ) async {
    transitionTo(ApplicationServiceLifecycleState.executing);
    if (request.action == 'fail') {
      transitionTo(ApplicationServiceLifecycleState.failed);
      return ApplicationServiceResult.failure(Exception('forced failure'));
    }
    final response = ServiceResponse(
      requestId: request.id,
      data: {'test': true},
      isSuccess: true,
    );
    transitionTo(ApplicationServiceLifecycleState.completed);
    return ApplicationServiceResult.success(response);
  }
}

class MockServiceObserver implements ApplicationServiceObserver {
  final List<ServiceExecutionContext> started = [];
  final List<ApplicationServiceResult<ServiceResponse>> finished = [];
  final List<Exception> failed = [];
  final List<ServiceExecutionContext> cancelled = [];
  final List<String> times = [];
  final List<String> logs = [];

  @override
  void onExecutionStarted(ServiceExecutionContext context) {
    started.add(context);
  }

  @override
  void onExecutionFinished(
    ServiceExecutionContext context,
    ApplicationServiceResult<ServiceResponse> result,
  ) {
    finished.add(result);
  }

  @override
  void onExecutionFailed(
    ServiceExecutionContext context,
    Exception exception,
    StackTrace? stackTrace,
  ) {
    failed.add(exception);
  }

  @override
  void onExecutionCancelled(ServiceExecutionContext context) {
    cancelled.add(context);
  }

  @override
  void onExecutionTimeRecorded(
    String serviceName,
    String action,
    Duration duration,
  ) {
    times.add('$serviceName.$action:${duration.inMilliseconds}ms');
  }

  @override
  void onDiagnosticLogged(
    String serviceName,
    String message, [
    Map<String, dynamic>? details,
  ]) {
    logs.add('[$serviceName] $message');
  }

  @override
  void onPerformanceMetricRecorded(
    String metricName,
    double value, [
    Map<String, String>? tags,
  ]) {}
}

class MockServiceValidator implements ApplicationServiceValidator {
  bool shouldValidateInput = true;
  bool shouldValidateRequest = true;
  bool shouldValidateResponse = true;
  bool shouldValidateExecution = true;

  @override
  bool validateInput(Map<String, dynamic> input) => shouldValidateInput;

  @override
  bool validateRequest(ServiceRequest request) => shouldValidateRequest;

  @override
  bool validateResponse(ServiceResponse response) => shouldValidateResponse;

  @override
  bool validateExecution(ServiceExecutionContext context) =>
      shouldValidateExecution;
}

void main() {
  group('Service Lifecycle Tests', () {
    test('Starts at created state', () {
      final service = TestService();
      expect(service.state, equals(ApplicationServiceLifecycleState.created));
    });

    test('Valid lifecycle transitions work successfully', () async {
      final service = TestService();
      const context = ApplicationServiceContext(environment: 'test');

      await service.initialize(context);
      expect(service.state, equals(ApplicationServiceLifecycleState.ready));

      final request = ServiceRequest(id: 'req-1', action: 'run');
      final result = await service.execute(request);

      expect(result.status, equals(ApplicationServiceResultStatus.success));
      expect(service.state, equals(ApplicationServiceLifecycleState.completed));

      await service.dispose();
      expect(service.state, equals(ApplicationServiceLifecycleState.disposed));
    });

    test('Invalid transitions throw StateError', () {
      final lifecycle = ApplicationServiceLifecycle();
      expect(
        () =>
            lifecycle.transitionTo(ApplicationServiceLifecycleState.completed),
        throwsStateError,
      );
    });
  });

  group('Service Result and Exception Model Tests', () {
    test('Result holds status outcomes correctly', () {
      final successResult = ApplicationServiceResult.success('data');
      expect(
        successResult.status,
        equals(ApplicationServiceResultStatus.success),
      );
      expect(successResult.data, equals('data'));

      final offlineResult = ApplicationServiceResult.offline();
      expect(
        offlineResult.status,
        equals(ApplicationServiceResultStatus.offline),
      );
    });

    test('ApplicationServiceException holds error details', () {
      final inner = Exception('database lock');
      final ex = ApplicationServiceException('Fetch failed', inner);

      expect(ex.message, equals('Fetch failed'));
      expect(ex.originalError, equals(inner));
      expect(ex.toString(), contains('Fetch failed'));
    });
  });

  group('Service Observers & Validators Tests', () {
    test('Observer records events successfully', () {
      final observer = MockServiceObserver();
      final context = ServiceExecutionContext(
        request: const ServiceRequest(id: 'req-1', action: 'test'),
        context: const ApplicationServiceContext(environment: 'dev'),
        startTime: DateTime.now(),
      );

      observer.onExecutionStarted(context);
      observer.onExecutionFinished(
        context,
        const ApplicationServiceResult.success(null),
      );
      observer.onExecutionFailed(context, Exception('fail'), null);
      observer.onExecutionCancelled(context);
      observer.onExecutionTimeRecorded(
        'UsageService',
        'fetch',
        const Duration(milliseconds: 15),
      );
      observer.onDiagnosticLogged('UsageService', 'fetched cache');

      expect(observer.started.length, equals(1));
      expect(observer.finished.length, equals(1));
      expect(observer.failed.length, equals(1));
      expect(observer.cancelled.length, equals(1));
      expect(observer.times.first, equals('UsageService.fetch:15ms'));
      expect(observer.logs.first, equals('[UsageService] fetched cache'));
    });

    test('Validator checks inputs', () {
      final validator = MockServiceValidator();
      expect(validator.validateInput({'key': 'val'}), isTrue);
      expect(
        validator.validateRequest(const ServiceRequest(id: 'r', action: 'a')),
        isTrue,
      );
    });
  });

  group('Dependency Injection & Placeholder Services Compatibility', () {
    setUp(() {
      AppServiceLocator.instance.reset();
    });

    test(
      'Composition root bootstrapper registers application services',
      () async {
        final bootstrapper = AppBootstrapper();
        final locator = await bootstrapper.bootstrap();

        expect(locator.isRegistered<UsageService>(), isTrue);
        expect(locator.isRegistered<ConversationService>(), isTrue);
        expect(locator.isRegistered<AnalyticsService>(), isTrue);
        expect(locator.isRegistered<SettingsService>(), isTrue);
        expect(locator.isRegistered<WidgetService>(), isTrue);
        expect(locator.isRegistered<SyncService>(), isTrue);

        final usage = locator.get<UsageService>();
        const context = ApplicationServiceContext(environment: 'production');
        await usage.initialize(context);
        expect(usage.state, equals(ApplicationServiceLifecycleState.ready));

        final request = ServiceRequest(id: '1', action: 'fetch');
        final result = await usage.execute(request);
        expect(result.status, equals(ApplicationServiceResultStatus.success));
        expect(result.data?.data['usage'], equals('placeholder_data'));
      },
    );
  });
}
