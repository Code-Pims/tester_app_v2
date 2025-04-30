import 'dart:collection';

import 'package:dojodex_instructor/features/chat/chat_screen.dart';
import 'package:dojodex_instructor/features/clubs/club_screen.dart';
import 'package:dojodex_instructor/features/clubs/add_theory_card_screen.dart';
import 'package:dojodex_instructor/features/lesson_schedule/attendance_report_screen.dart';
import 'package:dojodex_instructor/features/lesson_schedule/create_or_update_schedule_screen.dart';
import 'package:dojodex_instructor/features/lesson_schedule/lesson_schedule_screen.dart';
import 'package:dojodex_instructor/features/settings/settings_screen.dart';
import 'package:dojodex_instructor/features/student_lists/student_lists_screen.dart';
import 'package:dojodex_instructor/features/update_student/update_student_screen.dart';
import 'package:dojodex_instructor/features/user_search/user_search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/features/base/base_screen.dart';

class MainRouter implements DojoDexRouter {
  @override
  String get name => "main";

  final GlobalKey<NavigatorState> key = GlobalKey();

  // Indicate route endpoints here
  static const String base = '/';
  static const String home = 'home';
  static const String settings = 'settings';
  static const String club = 'club';
  static const String clubSpecificTheoryCard = 'clubSpecificTheoryCard';
  static const String clubStudentLists = 'clubStudentLists';
  static const String updateStudent = 'updateStudent';
  static const String chat = 'chat';
  static const String searchUser = 'search_user';
  static const String attendanceReportScreen = 'attendance_report_screen';
  static const String lessonSchedule = 'lesson_schedule';
  static const String createSchedule = 'create_schedule';
  static const String updateSchedule = 'update_schedule';

  final LinkedHashMap<String, RouteBuilder> routes = LinkedHashMap.from(
    <String, RouteBuilder>{
      base: ({settings}) => _buildRoute(
            const BaseScreen(),
            settings: settings,
          ),
      home: ({settings}) => _buildRoute(
            const SizedBox(),
            settings: settings,
          ),
      settings: ({settings}) => _buildRoute(
            const SettingsScreen(),
            settings: settings,
          ),
      club: ({settings}) => _buildRoute(
            ClubScreen(
              arguments: settings?.arguments as ClubArguments,
            ),
            settings: settings,
          ),
      clubSpecificTheoryCard: ({settings}) => _buildRoute(
            const AddTheoryCardScreen(),
            settings: settings,
          ),
      clubStudentLists: ({settings}) => _buildRoute(
            StudentListsScreen(
              arguments: settings?.arguments as StudentListsArguments,
            ),
            settings: settings,
          ),
      updateStudent: ({settings}) => _buildRoute(
            UpdateStudentScreen(
                arguments: settings?.arguments as UpdateStudentArguments),
            settings: settings,
          ),
      chat: ({settings}) => _buildRoute(
            ChatScreen(
              arguments: settings?.arguments as ChatArguments,
            ),
            settings: settings,
          ),
      searchUser: ({settings}) => _buildRoute(
            const UserSearchScreen(),
            settings: settings,
          ),
      lessonSchedule: ({settings}) => _buildRoute(
            const LessonScheduleScreen(),
            settings: settings,
          ),
      attendanceReportScreen: ({settings}) => _buildRoute(
            const AttendanceReportScreen(),
            settings: settings,
          ),
      createSchedule: ({settings}) => _buildRoute(
            CreateOrUpdateScheduleScreen(
              arguments: settings?.arguments as CreateOrUpdateScheduleArguments,
            ),
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
