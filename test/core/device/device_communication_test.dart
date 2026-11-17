import 'package:claudewatch/app/bootstrap/bootstrap.dart';
import 'package:claudewatch/app/bootstrap/locator_impl.dart';
import 'package:claudewatch/core/device/device_lifecycle.dart';
import 'package:claudewatch/core/device/device_metadata.dart';
import 'package:claudewatch/core/device/device_request_response.dart';
import 'package:claudewatch/core/device/device_command_event.dart';
import 'package:claudewatch/core/device/device_transport.dart';
import 'package:claudewatch/core/device/device_discovery.dart';
import 'package:claudewatch/core/device/communication_observer.dart';
import 'package:claudewatch/core/device/communication_validator.dart';
import 'package:claudewatch/app/device/device_lifecycle_coordinator.dart';
import 'package:claudewatch/app/device/device_session_manager.dart';
import 'package:claudewatch/shared/device/mock_device_transport.dart';
import 'package:claudewatch/shared/device/mock_device_discovery.dart';
import 'package:claudewatch/shared/device/mock_communication_observer.dart';
import 'package:claudewatch/shared/device/mock_communication_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Device Lifecycle Tests', () {
    test('Initial state is created', () {
      final lifecycle = DeviceLifecycle();
      expect(lifecycle.state, equals(DeviceLifecycleState.created));
    });

    test('Valid sequential transitions work successfully', () {
      final lifecycle = DeviceLifecycle();

      lifecycle.transitionTo(DeviceLifecycleState.scanning);
      expect(lifecycle.state, equals(DeviceLifecycleState.scanning));

      lifecycle.transitionTo(DeviceLifecycleState.discovered);
      expect(lifecycle.state, equals(DeviceLifecycleState.discovered));

      lifecycle.transitionTo(DeviceLifecycleState.pairing);
      expect(lifecycle.state, equals(DeviceLifecycleState.pairing));

      lifecycle.transitionTo(DeviceLifecycleState.connecting);
      expect(lifecycle.state, equals(DeviceLifecycleState.connecting));

      lifecycle.transitionTo(DeviceLifecycleState.connected);
      expect(lifecycle.state, equals(DeviceLifecycleState.connected));

      lifecycle.transitionTo(DeviceLifecycleState.authenticating);
      expect(lifecycle.state, equals(DeviceLifecycleState.authenticating));

      lifecycle.transitionTo(DeviceLifecycleState.ready);
      expect(lifecycle.state, equals(DeviceLifecycleState.ready));

      lifecycle.transitionTo(DeviceLifecycleState.disconnected);
      expect(lifecycle.state, equals(DeviceLifecycleState.disconnected));

      lifecycle.transitionTo(DeviceLifecycleState.reconnecting);
      expect(lifecycle.state, equals(DeviceLifecycleState.reconnecting));

      lifecycle.transitionTo(DeviceLifecycleState.disposed);
      expect(lifecycle.state, equals(DeviceLifecycleState.disposed));
    });

    test('Invalid transitions throw StateError', () {
      final lifecycle = DeviceLifecycle();
      expect(
        () => lifecycle.transitionTo(DeviceLifecycleState.ready),
        throwsStateError,
      );
    });

    test('Disposed state rejects further transitions', () {
      final lifecycle = DeviceLifecycle();
      lifecycle.transitionTo(DeviceLifecycleState.scanning);
      lifecycle.transitionTo(DeviceLifecycleState.disposed);

      expect(
        () => lifecycle.transitionTo(DeviceLifecycleState.connecting),
        throwsStateError,
      );
    });
  });

  group('Device Metadata Model Tests', () {
    test('DeviceCapabilities fields match constructor', () {
      const caps = DeviceCapabilities(
        supportedTransports: ['BLE', 'USB'],
        supportedSensors: ['Accelerometer', 'Gyroscope'],
        supportsStreaming: true,
        supportsAuthentication: true,
        supportsPairing: true,
      );
      expect(caps.supportsTransport('BLE'), isTrue);
      expect(caps.supportsTransport('HTTP'), isFalse);
      expect(caps.supportsStreaming, isTrue);
      expect(caps.supportsAuthentication, isTrue);
      expect(caps.supportsPairing, isTrue);
    });

    test('DeviceStatus and DeviceHealth hold expected data', () {
      const status = DeviceStatus(
        batteryLevel: 92,
        signalStrength: -55.5,
        firmwareVersion: '1.0.0',
        isCharging: false,
        freeMemoryBytes: 1024 * 1024,
        uptime: Duration(hours: 2),
      );
      expect(status.batteryLevel, equals(92));
      expect(status.signalStrength, equals(-55.5));
      expect(status.firmwareVersion, equals('1.0.0'));
      expect(status.isCharging, isFalse);
      expect(status.freeMemoryBytes, equals(1024 * 1024));
      expect(status.uptime, equals(const Duration(hours: 2)));

      const health = DeviceHealth(
        isHealthy: true,
        severity: HealthSeverity.nominal,
        diagnostics: {'voltage': 'normal'},
        errorCount: 0,
        temperatureCelsius: 24.5,
      );
      expect(health.isHealthy, isTrue);
      expect(health.severity, equals(HealthSeverity.nominal));
      expect(health.diagnostics['voltage'], equals('normal'));
      expect(health.errorCount, equals(0));
      expect(health.temperatureCelsius, equals(24.5));
    });
  });

  group('Request / Response Model Tests', () {
    test('DeviceRequest properties map correctly', () {
      final request = DeviceRequest(
        id: 'req-123',
        path: '/battery',
        payload: {'format': 'percentage'},
        timestamp: DateTime.utc(2026, 7, 25),
      );

      expect(request.id, equals('req-123'));
      expect(request.path, equals('/battery'));
      expect(request.payload['format'], equals('percentage'));
      expect(request.timestamp, equals(DateTime.utc(2026, 7, 25)));
    });

    test('DeviceResponse statuses are supported', () {
      final response = DeviceResponse(
        requestId: 'req-123',
        status: DeviceResponseStatus.success,
        payload: {'battery': 85},
        timestamp: DateTime.utc(2026, 7, 25),
      );

      expect(response.requestId, equals('req-123'));
      expect(response.status, equals(DeviceResponseStatus.success));
      expect(response.payload['battery'], equals(85));
    });
  });

  group('Event Model and Dispatch Tests', () {
    test('DeviceEvent holds type, deviceId, timestamp and details', () {
      final timestamp = DateTime.now();
      final event = DeviceEvent(
        type: DeviceEventType.connected,
        deviceId: 'dev-123',
        timestamp: timestamp,
        data: {'signal': -40.0},
      );

      expect(event.type, equals(DeviceEventType.connected));
      expect(event.deviceId, equals('dev-123'));
      expect(event.timestamp, equals(timestamp));
      expect(event.data['signal'], equals(-40.0));
    });

    test('MockDeviceTransport dispatches events successfully', () async {
      final transport = MockDeviceTransport();
      final event = DeviceEvent(
        type: DeviceEventType.healthChanged,
        deviceId: 'dev-123',
        timestamp: DateTime.now(),
        data: {'battery': 80},
      );

      final eventsStream = transport.listenEvents('dev-123');

      expect(
        eventsStream,
        emits(
          predicate<DeviceEvent>(
            (e) =>
                e.type == DeviceEventType.healthChanged &&
                e.deviceId == 'dev-123',
          ),
        ),
      );

      transport.triggerMockEvent(event);
    });
  });

  group('Validation Tests', () {
    test('MockCommunicationValidator validates command inputs', () {
      final validator = MockCommunicationValidator();
      final command = DeviceCommand(
        id: 'cmd-1',
        name: 'reboot',
        timestamp: DateTime.now(),
      );

      expect(validator.validateCommand(command), isTrue);

      final emptyCommand = DeviceCommand(
        id: 'cmd-2',
        name: '',
        timestamp: DateTime.now(),
      );
      expect(validator.validateCommand(emptyCommand), isFalse);
    });

    test('MockCommunicationValidator validates authentication inputs', () {
      final validator = MockCommunicationValidator();

      expect(validator.validateAuthentication({'pin': '1234'}), isTrue);
      expect(validator.validateAuthentication({'token': 'valid'}), isTrue);
      expect(validator.validateAuthentication({'user': 'admin'}), isFalse);
    });
  });

  group('Observer Notification Tests', () {
    test('MockCommunicationObserver records notifications', () {
      final observer = MockCommunicationObserver();
      final command = DeviceCommand(
        id: 'cmd-1',
        name: 'ping',
        timestamp: DateTime.now(),
      );
      final request = DeviceRequest(
        id: 'req-1',
        path: '/status',
        timestamp: DateTime.now(),
      );
      final response = DeviceResponse(
        requestId: 'req-1',
        status: DeviceResponseStatus.success,
        timestamp: DateTime.now(),
      );
      final event = DeviceEvent(
        type: DeviceEventType.disconnected,
        deviceId: 'dev-1',
        timestamp: DateTime.now(),
      );

      observer.onCommandSent(command);
      observer.onCommandReceived(command);
      observer.onRequestSent(request);
      observer.onResponseReceived(response);
      observer.onEventReceived(event);
      observer.onError('dev-1', Exception('disconnect failure'));
      observer.onMetricRecorded('rssi', -72.0);

      expect(observer.sentCommands.length, equals(1));
      expect(observer.receivedCommands.length, equals(1));
      expect(observer.sentRequests.length, equals(1));
      expect(observer.receivedResponses.length, equals(1));
      expect(observer.receivedEvents.length, equals(1));
      expect(observer.errors.length, equals(1));
      expect(observer.metrics.length, equals(1));
    });
  });

  group('Dependency Injection & Bootstrapper Integration', () {
    setUp(() {
      AppServiceLocator.instance.reset();
    });

    test(
      'DI bootstrap successfully registers device communication classes',
      () async {
        final bootstrapper = AppBootstrapper();
        final locator = await bootstrapper.bootstrap();

        expect(locator.isRegistered<DeviceTransport>(), isTrue);
        expect(locator.isRegistered<DeviceScanner>(), isTrue);
        expect(locator.isRegistered<DevicePairing>(), isTrue);
        expect(locator.isRegistered<DeviceAuthentication>(), isTrue);
        expect(locator.isRegistered<CommunicationObserver>(), isTrue);
        expect(locator.isRegistered<CommunicationValidator>(), isTrue);
        expect(locator.isRegistered<DeviceLifecycleCoordinator>(), isTrue);
        expect(locator.isRegistered<DeviceSessionManager>(), isTrue);

        expect(locator.get<DeviceTransport>(), isA<MockDeviceTransport>());
        expect(locator.get<DeviceScanner>(), isA<MockDeviceScanner>());
        expect(locator.get<DevicePairing>(), isA<MockDevicePairing>());
        expect(
          locator.get<DeviceAuthentication>(),
          isA<MockDeviceAuthentication>(),
        );
        expect(
          locator.get<CommunicationObserver>(),
          isA<MockCommunicationObserver>(),
        );
        expect(
          locator.get<CommunicationValidator>(),
          isA<MockCommunicationValidator>(),
        );
      },
    );
  });

  group('Mock Compatibility / Scanner & Pairing Tests', () {
    test('MockDeviceScanner registers scan start/stop', () async {
      final scanner = MockDeviceScanner();
      expect(scanner.isScanning, isFalse);

      final scanFuture = scanner.onDiscoveredDevices.first;
      await scanner.startScan();
      expect(scanner.isScanning, isTrue);

      final devices = await scanFuture;
      expect(devices.length, equals(2));
      expect(devices.first.name, equals('ClaudeWatch v1'));

      await scanner.stopScan();
      expect(scanner.isScanning, isFalse);
    });

    test('MockDevicePairing and Authentication works successfully', () async {
      final pairing = MockDevicePairing();
      final auth = MockDeviceAuthentication();

      expect(await pairing.isPaired('dev-1'), isFalse);
      await pairing.pair('dev-1');
      expect(await pairing.isPaired('dev-1'), isTrue);

      expect(await auth.isAuthenticated('dev-1'), isFalse);
      expect(await auth.authenticate('dev-1', {'pin': 'wrong'}), isFalse);
      expect(await auth.authenticate('dev-1', {'pin': '1234'}), isTrue);
      expect(await auth.isAuthenticated('dev-1'), isTrue);
    });
  });
}
