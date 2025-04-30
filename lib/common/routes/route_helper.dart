import 'package:dojodex_instructor/common/routes/onboarding_router.dart';
import 'package:dojodex_instructor/features/chat/chat_screen.dart';
import 'package:dojodex_instructor/features/clubs/club_screen.dart';
import 'package:dojodex_instructor/features/lesson_schedule/create_or_update_schedule_screen.dart';
import 'package:dojodex_instructor/features/student_lists/student_lists_screen.dart';
import 'package:dojodex_instructor/features/update_student/update_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:dojodex_instructor/common/routes/main_router.dart';
import 'package:dojodex_instructor/common/routes/root_router.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';

typedef RouteBuilder = Route<dynamic> Function({RouteSettings? settings});

abstract class DojoDexRouter {
  String get name;
}

/// The class which oversees every route states and it serves as helper to any
/// UI components that need it.
class RouteHelper {
  @protected
  RootRouter get rootRouter => sl<RootRouter>();

  @protected
  MainRouter get mainRouter => sl<MainRouter>();

  @protected
  OnboardingRouter get onboardingRouter => sl<OnboardingRouter>();

  /// ROOT routes
  /// ************************************************************

  /// MAIN routes
  /// ************************************************************
  void navigateToBaseScreen() {
    mainRouter.key.currentState?.pushReplacementNamed(
      MainRouter.base,
    );
  }

  void showHomeScreen() {
    mainRouter.key.currentState?.pushNamed(
      MainRouter.home,
    );
  }

  void showSettingsScreen() {
    mainRouter.key.currentState?.pushNamed(
      MainRouter.settings,
    );
  }

  Future<void> showClubScreen(ClubArguments clubArguments) async {
    await mainRouter.key.currentState?.pushNamed(
      MainRouter.club,
      arguments: clubArguments,
    );
  }

  Future<void> showClubSpecificTheoryCard() async {
    await mainRouter.key.currentState?.pushNamed(
      MainRouter.clubSpecificTheoryCard,
    );
  }

  Future<void> showClubStudentLists(
      StudentListsArguments studentListsArguments) async {
    await mainRouter.key.currentState?.pushNamed(
      MainRouter.clubStudentLists,
      arguments: studentListsArguments,
    );
  }

  Future<void> showUpdateStudent(
      UpdateStudentArguments updateStudentArguments) async {
    await mainRouter.key.currentState?.pushNamed(
      MainRouter.updateStudent,
      arguments: updateStudentArguments,
    );
  }

  void showChatScreen(ChatArguments arguments) {
    mainRouter.key.currentState?.pushNamed(
      MainRouter.chat,
      arguments: arguments,
    );
  }

  void showLessonScheduleScreen() {
    mainRouter.key.currentState?.pushNamed(
      MainRouter.lessonSchedule,
    );
  }

  void showAttendanceReportScreen() {
    mainRouter.key.currentState?.pushNamed(
      MainRouter.attendanceReportScreen,
    );
  }

  void showCreateScheduleScreen({CreateOrUpdateScheduleArguments? arguments}) {
    mainRouter.key.currentState?.pushNamed(
      MainRouter.createSchedule,
      arguments: arguments,
    );
  }

  Future<dynamic> showUserSearchScreen() async {
    return await mainRouter.key.currentState?.pushNamed(
      MainRouter.searchUser,
    );
  }

  void popToPreviousPage({dynamic result}) {
    if (mainRouter.key.currentState?.canPop() ?? false) {
      mainRouter.key.currentState?.pop(result);
    }
  }

  // defaults
  void popMainToRoot() {
    mainRouter.key.currentState?.popUntil((route) => route.isFirst);
  }

  /// ONBOARDING routes
  /// ************************************************************
  ///

  void showLoginScreen() {
    onboardingRouter.key.currentState?.pushNamed(
      OnboardingRouter.login,
    );
  }

  void showRegisterScreen() {
    onboardingRouter.key.currentState?.pushNamed(
      OnboardingRouter.register,
    );
  }
}
