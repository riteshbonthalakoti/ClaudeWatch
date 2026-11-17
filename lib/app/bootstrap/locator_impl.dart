import 'package:claudewatch/core/di/service_locator.dart';

class ServiceLocatorException implements Exception {
  final String message;
  ServiceLocatorException(this.message);
  @override
  String toString() => 'ServiceLocatorException: $message';
}

class AppServiceLocator implements ServiceLocator {
  static final AppServiceLocator instance = AppServiceLocator._();
  AppServiceLocator._();

  final Map<Type, Object Function()> _factories = {};
  final Map<Type, Object> _singletons = {};
  bool _allowOverrides = false;

  @override
  void registerSingleton<T extends Object>(T instance) {
    _verifyRegistration<T>();
    _singletons[T] = instance;
    _factories[T] = () => instance;
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _verifyRegistration<T>();
    _factories[T] = () {
      if (!_singletons.containsKey(T)) {
        _singletons[T] = factory();
      }
      return _singletons[T]!;
    };
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _verifyRegistration<T>();
    _factories[T] = factory;
  }

  @override
  T get<T extends Object>() {
    final factory = _factories[T];
    if (factory == null) {
      throw ServiceLocatorException(
        'Missing dependency registration for type: $T',
      );
    }
    return factory() as T;
  }

  @override
  bool isRegistered<T extends Object>() {
    return _factories.containsKey(T);
  }

  bool isRegisteredType(Type type) {
    return _factories.containsKey(type);
  }

  @override
  void unregister<T extends Object>() {
    _factories.remove(T);
    _singletons.remove(T);
  }

  @override
  void allowOverrides(bool allow) {
    _allowOverrides = allow;
  }

  void _verifyRegistration<T>() {
    if (_factories.containsKey(T) && !_allowOverrides) {
      throw ServiceLocatorException(
        'Duplicate registration detected for type: $T',
      );
    }
  }

  void reset() {
    _factories.clear();
    _singletons.clear();
    _allowOverrides = false;
  }
}
