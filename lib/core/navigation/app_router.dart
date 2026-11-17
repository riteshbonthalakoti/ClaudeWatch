abstract class AppRouter {
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  });
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  });
  void pop<T extends Object?>([T? result]);
  void goBack();
}
