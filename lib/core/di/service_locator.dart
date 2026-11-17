abstract class ServiceLocator {
  void registerSingleton<T extends Object>(T instance);
  void registerLazySingleton<T extends Object>(T Function() factory);
  void registerFactory<T extends Object>(T Function() factory);
  T get<T extends Object>();
  bool isRegistered<T extends Object>();
  void unregister<T extends Object>();
  void allowOverrides(bool allow);
}
