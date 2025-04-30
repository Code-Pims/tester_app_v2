import 'package:dojodex_common/dojodex_string_utils.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dojodex_instructor/common/routes/root_router.dart';
import 'package:dojodex_instructor/dependencies/app_dependency_provider.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/landing/landing_screen.dart';
import 'package:dojodex_instructor/generated/l10n.dart';

class DojoDexApp extends StatelessWidget {
  final DependencyManager dependencyManager;
  const DojoDexApp({
    super.key,
    required this.dependencyManager,
  });

  @override
  Widget build(BuildContext context) {
    final rootRouter = sl.get<RootRouter>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "DojoDex",
      navigatorKey: rootRouter.key,
      onGenerateRoute: rootRouter.getRoute,
      theme: AppThemes.defaultStyle,
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      locale: const Locale("en", "GB"),
      supportedLocales: const [
        Locale('en', 'UK'),
      ],
      home: GestureDetector(
        onTap: hideKeyboard,
        child: AppDependencyProvider(
          child: LandingScreen(
            dependencyManager: dependencyManager,
          ),
        ),
      ),
    );
  }
}
