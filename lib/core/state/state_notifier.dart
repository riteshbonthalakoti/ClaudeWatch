import 'package:flutter/foundation.dart';

abstract class AppStateNotifier<T> extends ValueNotifier<T> {
  AppStateNotifier(super.value);

  @protected
  void updateState(T newState) {
    value = newState;
  }
}
