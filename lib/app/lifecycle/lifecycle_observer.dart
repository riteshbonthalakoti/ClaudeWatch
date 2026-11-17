import 'package:claudewatch/app/lifecycle/lifecycle_state.dart';

abstract class AppLifecycleObserver {
  void onLifecycleTransition(AppLifecycleStage from, AppLifecycleStage to);
}
