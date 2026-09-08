import 'package:flutter/material.dart';
import '../routes/routes_stage.dart';

class StagePage extends StatelessWidget {
  const StagePage({required this.onVisibiliteNavigationChangee, super.key});

  final ValueChanged<bool> onVisibiliteNavigationChangee;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: RoutesStage.accueil,
      onGenerateRoute: RoutesStage.generer,
      observers: [
        _ObservateurRoutesStage(onVisibiliteNavigationChangee),
      ],
    );
  }
}

class _ObservateurRoutesStage extends NavigatorObserver {
  _ObservateurRoutesStage(this.onVisibiliteChangee);

  final ValueChanged<bool> onVisibiliteChangee;

  void _notifier(bool visible) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onVisibiliteChangee(visible);
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notifier(route.isFirst);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notifier(previousRoute?.isFirst ?? true);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notifier(newRoute?.isFirst ?? false);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _notifier(true);
  }
}
