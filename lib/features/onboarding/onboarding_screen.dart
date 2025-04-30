import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:flutter/material.dart';

import '../../common/routes/onboarding_router.dart';

/// A top level screen container holding every screens in the onboarding process.
/// Please check [OnboardingRouter].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = sl.get<OnboardingRouter>();

    return Navigator(
      key: router.key,
      observers: [
        HeroController(),
      ],
      onGenerateRoute: router.getRoute,
      initialRoute: OnboardingRouter.login,
    );
  }
}
