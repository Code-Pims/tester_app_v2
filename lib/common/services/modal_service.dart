import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

import '../routes/main_router.dart';
import '../routes/root_router.dart';
import '../routes/route_helper.dart';

typedef ModalWidgetBuilder = Widget Function(ModalActions modalActions);

enum ModalTransitionType { slideDown, centerPopUp }

class ModalActions {
  const ModalActions({required this.dismiss});

  final Function() dismiss;
}

/// Utility to manage root level widgets. This is meant to be used by modal type
/// widgets such as dialogs, tutorial banners, and custom widgets which is
/// intended to be drawn on top of the main screens. Check [RootRouter],
/// for [MainRouter], [RouteHelper] navigation structure reference.
class ModalService {
  bool isShowingSomething = false;

  // Meant to prevent simultaneous calls to presentation of modals
  final Mutex _mutex = Mutex();

  Future<dynamic> show(
    ModalWidgetBuilder builder, {
    bool barrierDismissible = false,
    ModalTransitionType transitionType = ModalTransitionType.centerPopUp,
  }) async {
    await _mutex.acquire();

    try {
      isShowingSomething = true;
      if (sl<MainRouter>().key.currentState != null) {
        return await sl<MainRouter>().key.currentState?.push(
              _buildRoute(
                builder,
                barrierDismissable: barrierDismissible,
                transitionType: transitionType,
              ),
            );
      }
      if (sl<RootRouter>().key.currentState != null) {
        return await sl<RootRouter>().key.currentState?.push(
              _buildRoute(
                builder,
                barrierDismissable: barrierDismissible,
                transitionType: transitionType,
              ),
            );
      }
      return await sl<MainRouter>().key.currentState?.push(
            _buildRoute(
              builder,
              barrierDismissable: barrierDismissible,
              transitionType: transitionType,
            ),
          );
    } finally {
      isShowingSomething = false;
      _mutex.release();
    }
  }

  Future<void> dismissTop() async {
    if (isShowingSomething) {
      sl<RootRouter>().key.currentState?.pop();
    }
  }

  PageRoute<T?> _buildRoute<T>(
    ModalWidgetBuilder childBuilder, {
    bool barrierDismissable = false,
    ModalTransitionType transitionType = ModalTransitionType.centerPopUp,
  }) {
    final RouteTransitionsBuilder routeTransitionsBuilder;
    switch (transitionType) {
      case ModalTransitionType.slideDown:
        routeTransitionsBuilder = _buildSlideDownTransition;
        break;
      case ModalTransitionType.centerPopUp:
        routeTransitionsBuilder = _buildCenterPopUpTransition;
    }

    return PageRouteBuilder<T?>(
      opaque: false,
      barrierColor: Colors.black87,
      fullscreenDialog: true,
      barrierDismissible: barrierDismissable,
      transitionDuration: const Duration(milliseconds: 550),
      transitionsBuilder: routeTransitionsBuilder,
      pageBuilder: (context, anim1, anim2) {
        return childBuilder(ModalActions(dismiss: () {
          Navigator.of(context).pop();
        }));
      },
    );
  }

  Widget _buildCenterPopUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.ease;

    final tween = Tween<double>(begin: 0, end: 1).chain(
      CurveTween(curve: curve),
    );

    final drive = animation.drive(tween);
    return FadeTransition(
      opacity: drive,
      child: ScaleTransition(
        scale: drive,
        child: child,
      ),
    );
  }

  Widget _buildSlideDownTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0, -1);
    const end = Offset.zero;
    const curve = Curves.easeIn;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    final drive = animation.drive(tween);
    return SlideTransition(
      position: drive,
      child: child,
    );
  }
}
