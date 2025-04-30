import 'dart:collection';

import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/features/login/login_screen.dart';
import 'package:dojodex_instructor/features/register/register_screen.dart';
import 'package:flutter/cupertino.dart';

class OnboardingRouter implements DojoDexRouter {
  @override
  String get name => "onboarding";

  final GlobalKey<NavigatorState> key = GlobalKey();

  static const String login = 'login';
  static const String register = 'register';

  final LinkedHashMap<String, RouteBuilder> routes = LinkedHashMap.from(
    <String, RouteBuilder>{
      login: ({settings}) => _buildRoute(
            const LoginScreen(),
            settings: settings,
          ),
      register: ({settings}) => _buildRoute(
            const RegisterScreen(),
            settings: settings,
          ),
    },
  );

  /// The route being passed in [Navigator]'s onGenerateRoute
  Route getRoute(RouteSettings settings) {
    final route = routes[settings.name];
    assert(route != null, "Route is not declared");
    return route!(settings: settings);
  }

  static Route<T> _buildRoute<T>(
    Widget child, {
    required RouteSettings? settings,
    bool fullScreenDialog = false,
  }) {
    return CupertinoPageRoute<T>(
      settings: settings,
      fullscreenDialog: fullScreenDialog,
      builder: (context) {
        return child;
      },
    );
  }
}
