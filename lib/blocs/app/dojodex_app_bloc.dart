import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dojodex_common/models/grades/grade.dart';
import 'package:dojodex_common/models/user_preference/user_preference.dart';
import 'package:dojodex_instructor/common/const/preference_keys.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DojoDexBloc extends Cubit<DojoDexAppState> {
  DojoDexBloc() : super(DojoDexAppState());

  Future<void> initializeApp(DependencyManager dependencyManager) async {
    emit(state.copyWith(
      initialized: false,
      error: null,
      showSplashScreen: true,
    ));

    // Fake splash screen
    await Future.delayed(const Duration(seconds: 2));

    // to make sure dependencies were initialized well
    // before we proceed to the next screen
    // this is to avoid any errors that might occur
    if (dependencyManager.initialized == true) {
      await onColdStart();
      emit(state.copyWith(initialized: true, showSplashScreen: false));
      return;
    }

    try {
      await dependencyManager.init();
      await onColdStart();
      emit(state.copyWith(initialized: true, showSplashScreen: false));
    } catch (e, stackTrace) {
      Logger()
          .e("DEPENDENCY ERROR WENT HERE", error: e, stackTrace: stackTrace);
      emit(state.copyWith(error: e, showSplashScreen: false));
    }
  }

  /// Verify if the app is a fresh install
  Future<void> verifyFreshInstall() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final isFreshInstall =
        sharedPreferences.getBool(PreferenceKeys.isFreshInstall) ?? true;

    if (isFreshInstall) {
      sl<Logger>().i("Fresh install");
      emit(state.copyWith(hasSetUserPreference: false));
      return;
      // await sharedPreferences.setBool(PreferenceKeys.isFreshInstall, false);
    }

    emit(state.copyWith(hasSetUserPreference: true));
  }

  Future<void> onColdStart() async {
    // Verify fresh install
    await verifyFreshInstall();
  }
}

class DojoDexAppState {
  final bool initialized;
  final dynamic error;
  final bool? showSplashScreen;
  final bool? hasSetUserPreference;
  final bool? isSavingUserPreference;
  final List<UserPreference>? usersPreference;

  DojoDexAppState({
    this.initialized = false,
    this.showSplashScreen = false,
    this.error,
    this.hasSetUserPreference,
    this.isSavingUserPreference,
    this.usersPreference,
  });

  DojoDexAppState copyWith({
    bool? initialized,
    dynamic error,
    bool? showSplashScreen,
    bool? hasSetUserPreference,
    bool? isSavingUserPreference,
    List<UserPreference>? usersPreference,
  }) {
    return DojoDexAppState(
      initialized: initialized ?? this.initialized,
      error: error ?? this.error,
      showSplashScreen: showSplashScreen ?? this.showSplashScreen,
      hasSetUserPreference: hasSetUserPreference ?? this.hasSetUserPreference,
      isSavingUserPreference:
          isSavingUserPreference ?? this.isSavingUserPreference,
      usersPreference: usersPreference ?? this.usersPreference,
    );
  }
}

Grade findGradeByName(List<Grade> grades, String name) {
  return grades.firstWhere((grade) => grade.name == name,
      orElse: () => throw Exception('Grade not found'));
}
