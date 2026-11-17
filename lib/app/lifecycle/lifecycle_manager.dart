import 'package:claudewatch/app/lifecycle/lifecycle_observer.dart';
import 'package:claudewatch/app/lifecycle/lifecycle_state.dart';

class AppLifecycleManager {
  static final AppLifecycleManager instance = AppLifecycleManager._();
  AppLifecycleManager._();

  AppLifecycleStage _currentStage = AppLifecycleStage.processStarted;
  final List<AppLifecycleObserver> _observers = [];

  AppLifecycleStage get currentStage => _currentStage;

  void addObserver(AppLifecycleObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  void removeObserver(AppLifecycleObserver observer) {
    _observers.remove(observer);
  }

  void transitionTo(AppLifecycleStage nextStage) {
    if (nextStage == _currentStage) return;

    // Validate transition order
    if (!_isValidTransition(_currentStage, nextStage)) {
      throw StateError(
        'Invalid lifecycle transition from $_currentStage to $nextStage',
      );
    }

    final previousStage = _currentStage;
    _currentStage = nextStage;

    // Notify observers
    for (final observer in List<AppLifecycleObserver>.from(_observers)) {
      observer.onLifecycleTransition(previousStage, nextStage);
    }
  }

  bool _isValidTransition(AppLifecycleStage from, AppLifecycleStage to) {
    // ProcessStarted must transition to Bootstrap
    if (from == AppLifecycleStage.processStarted) {
      return to == AppLifecycleStage.bootstrap;
    }
    // Bootstrap transitions to DependencyRegistration
    if (from == AppLifecycleStage.bootstrap) {
      return to == AppLifecycleStage.dependencyRegistration;
    }
    // DependencyRegistration transitions to ConfigurationLoaded
    if (from == AppLifecycleStage.dependencyRegistration) {
      return to == AppLifecycleStage.configurationLoaded;
    }
    // ConfigurationLoaded transitions to NavigationReady
    if (from == AppLifecycleStage.configurationLoaded) {
      return to == AppLifecycleStage.navigationReady;
    }
    // NavigationReady transitions to UIReady
    if (from == AppLifecycleStage.navigationReady) {
      return to == AppLifecycleStage.uiReady;
    }
    // UIReady transitions to Running
    if (from == AppLifecycleStage.uiReady) {
      return to == AppLifecycleStage.running;
    }
    // Running transitions to Background/Shutdown
    if (from == AppLifecycleStage.running) {
      return to == AppLifecycleStage.background ||
          to == AppLifecycleStage.shutdown;
    }
    // Background transitions to Foreground/Shutdown
    if (from == AppLifecycleStage.background) {
      return to == AppLifecycleStage.foreground ||
          to == AppLifecycleStage.shutdown;
    }
    // Foreground transitions to Running/Background/Shutdown
    if (from == AppLifecycleStage.foreground) {
      return to == AppLifecycleStage.running ||
          to == AppLifecycleStage.background ||
          to == AppLifecycleStage.shutdown;
    }
    // Shutdown is terminal
    return false;
  }

  void reset() {
    _currentStage = AppLifecycleStage.processStarted;
    _observers.clear();
  }
}
