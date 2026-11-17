import 'package:claudewatch/app/navigation/navigation_service.dart';
import 'package:claudewatch/core/navigation/app_router.dart';

class AppRouterAdapter implements AppRouter {
  final NavigationService _navigationService;

  AppRouterAdapter(this._navigationService);

  @override
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return _navigationService.navigateTo<T>(routeName, arguments: arguments);
  }

  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return _navigationService.replaceWith<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  @override
  void pop<T extends Object?>([T? result]) {
    _navigationService.goBack<T>(result);
  }

  @override
  void goBack() {
    _navigationService.goBack();
  }
}
