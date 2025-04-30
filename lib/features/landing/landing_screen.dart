import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
import 'package:dojodex_instructor/common/routes/main_router.dart';
import 'package:dojodex_instructor/common/routes/onboarding_router.dart';
import 'package:dojodex_instructor/dependencies/authenticated_dependency_provider.dart';
import 'package:dojodex_instructor/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dojodex_instructor/blocs/app/dojodex_app_bloc.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/main/main_screen.dart';
import 'package:dojodex_instructor/features/splash/splash_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LandingScreen extends StatefulWidget {
  final DependencyManager dependencyManager;
  const LandingScreen({
    super.key,
    required this.dependencyManager,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool? canPop;
  @override
  void initState() {
    context.read<DojoDexBloc>().initializeApp(widget.dependencyManager);
    sl<FToast>().init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        /// don't pop when in base screen
        // canPop: canPop ?? false,
        canPop: false,
        onPopInvokedWithResult: (didPop, dynamic) async {
          final handledOnboardingPop =
              !(await sl<OnboardingRouter>().key.currentState?.maybePop() ??
                  false);

          final handledMainPop =
              !(await sl<MainRouter>().key.currentState?.maybePop() ?? false);

          setState(() {
            canPop = handledOnboardingPop && handledMainPop;
          });
        },
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 275),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.fastOutSlowIn,
              child: _buildLandingScreen(),
            ),
            // Add busy indicator if necessary
          ],
        ),
      ),
    );
  }

  Widget _buildLandingScreen() {
    return BlocConsumer<DojoDexBloc, DojoDexAppState>(
      listenWhen: (previous, current) =>
          previous.initialized != current.initialized,
      listener: (context, appState) {
        if (appState.initialized) {
          context.read<AuthenticationBloc>().init();
        }
      },
      buildWhen: (previous, current) => previous != current,
      builder: (context, appState) {
        if (appState.showSplashScreen ?? false) {
          return const SplashScreen();
        }
        return BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, state) {
            if (state.user != null) {
              return;
            }
          },
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state.user == null) {
              return const OnboardingScreen();
            }

            /// Check if user is authenticated
            /// The user this time is intended to be unauthenticated
            if (state.user?.isAuthenticated == false) {
              return const OnboardingScreen();
            }

            return const AuthenticatedDependencyProvider(
              child: MainScreen(),
            );
          },
        );
      },
    );
  }
}
