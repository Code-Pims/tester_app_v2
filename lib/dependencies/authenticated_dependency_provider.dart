import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/blocs/lesson/lesson_bloc.dart';
import 'package:dojodex_instructor/blocs/setting/setting_bloc.dart';
import 'package:dojodex_instructor/blocs/sp_message/sp_message_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// Provides context-based and disposable dependencies such as providers and
/// widget type services. This is mainly used to wrap high tree level widgets in
/// this case, [MainScreen].
///
/// A higher level (application) dependency provider similar to this is defined.
/// Check [AuthenticatedDependencyProvider].
class AuthenticatedDependencyProvider extends StatelessWidget {
  const AuthenticatedDependencyProvider({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          lazy: true,
          create: (_) => ClubBloc(),
        ),
        BlocProvider(
          lazy: true,
          create: (_) => SettingBloc(),
        ),
        BlocProvider(
          lazy: true,
          create: (_) => LessonBloc(),
        ),
        BlocProvider<SpMessageBloc>(
          lazy: true,
          create: (_) => SpMessageBloc(),
        ),
      ],
      child: child,
    );
  }
}
