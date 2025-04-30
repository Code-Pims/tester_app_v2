import 'dart:core';

import 'package:dojodex_common/models/attendance/attendance.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_instructor/common/architecture/supabase_base_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/sqflite_helper/sqflite_attendees_list.dart';
import '../database/sqflite_helper/update_attendees_offline.dart';

class SupabaseAttendanceRepository extends SupabaseBaseRepository {
  SupabaseAttendanceRepository({required SupabaseClient supabase})
      : super(supabase);

  Future<List<LessonSchedule>?> fetchMyLessonSchedules({
    required String clubId,
  }) async {
    try {
      final response = await supabase
          .from(lessonScheduleTable)
          .select()
          .eq('club_id', clubId);

      final data = response as List<dynamic>;

      return data.map((json) => LessonSchedule.fromJson(json)).toList();
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<void> insertMultipleAttendees({
    required List<Attendance> attendees,
  }) async {
    var connectivityResult = await InternetConnection().hasInternetAccess;
    final UpdateAttendeesOffline updateAttendeesLocalDB =
        UpdateAttendeesOffline();

    debugPrint("Into insertMultipleAttendees");

    if (!connectivityResult) {
      try {
        // Save data locally when offline
        updateAttendeesLocalDB.clearOfflineData();

        for (var attendee in attendees) {
          Map<String, dynamic> attendeeMap = {
            "id": attendee.id,
            "club_id": attendee.clubID,
            "lesson_sched_id": attendee.lessonschedID,
            "student_id": attendee.studentId,
            "on_time": attendee.onTime,
            "last_session_date": attendee.lastSessionDate,
          };

          await updateAttendeesLocalDB.insertOfflineData(attendeeMap);
          debugPrint('insertMultipleAttendees into local DB done');
        }

        ///storeAttendees data into local DB
        List<Map<String, dynamic>> attendeesList =
            attendees.map((attendee) => attendee.toJson()).toList();

        await storeAttendeesListIntoLocalDB(attendeesList);
      } on Exception catch (e) {
        sl<Logger>().e(e);
        rethrow;
      }
    } else {
      try {
        final logger = sl<Logger>();
        await supabase.from(attendanceTable).delete().neq('id', 0);

        logger.i('Inserting multiple attendees $attendees');
        await supabase.from(attendanceTable).insert(
              attendees
                  .map(
                    (e) => e.toJson()
                      ..remove('id')
                      ..remove('created_at')
                      ..remove('last_session_date')
                      ..remove('is_uploaded'),
                  )
                  .toList(),
            );

        ///storeAttendees data into local DB
        List<Map<String, dynamic>> attendeesList =
            attendees.map((attendee) => attendee.toJson()).toList();

        await storeAttendeesListIntoLocalDB(attendeesList);
      } on Exception catch (e) {
        sl<Logger>().e(e);
        rethrow;
      }
    }
  }

  Future<void> deleteLessonSchedule({required int id}) async {
    try {
      await supabase.from(lessonScheduleTable).delete().eq('id', id);
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  /// Fetch all attendees for a lesson schedule
  /// the supabase RPC is get_attendance_status
  /// for example get_attendance_status(3, '2025-03-14')
  /// where 3 is the lesson schedule id and '2025-03-14' is the date
  Future<List<Attendance>?> fetchAttendees(int lessonScheduleId) async {
    if (await InternetConnection().hasInternetAccess) {
      try {
        final response = await supabase.rpc('get_attendees', params: {
          'lesson_sched': lessonScheduleId,
          'target_date': DateTime.now().toIso8601String(),
        });

        final data = response as List<dynamic>;

        final attendeesList = (data)
            .map(
              (e) => Attendance.fromJson(e),
            )
            .toList();

        ///storeAttendees data into local DB
        List<Map<String, dynamic>> attendees =
            attendeesList.map((attendee) => attendee.toJson()).toList();

        await storeAttendeesListIntoLocalDB(attendees);

        return attendeesList;
      } on Exception catch (e) {
        sl<Logger>().e(e);
        rethrow;
      }
    } else {
      return await fetchAttendeesListFromLocalDB();
    }
  }

  /// storeAttendeesListIntoLocalDB
  Future<void> storeAttendeesListIntoLocalDB(
      List<Map<String, dynamic>> attendeesList) async {
    try {
      final dbHelper = SqfliteAttendeesList();

      // Optional: Clear old data before inserting new
      await dbHelper.clearDatabase();

      for (var attendee in attendeesList) {
        await dbHelper.insertAttendance({
          'id': attendee['id'],
          'lesson_sched_id': attendee['lesson_sched_id'],
          'student_id': attendee['student_id'],
          'club_id': attendee['club_id'],
          'on_time': attendee['on_time'],
          'last_session_date': attendee['last_session_date'],
        });
      }

      debugPrint("Attendees List stored into local DB done");
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<List<Attendance>?> fetchAttendeesListFromLocalDB() async {
    try {
      final dbHelper = SqfliteAttendeesList();
      List<Map<String, dynamic>> attendees = await dbHelper.getAttendance();

      debugPrint("In fetchAttendeesListFromLocalDB");

      final lists = (attendees as List)
          .map(
            (e) => Attendance.fromJson(e),
          )
          .toList();

      return lists;
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<List<Attendance>?> fetchAllAttendeesOfSelectedClub(
      int clubId) async {
    try {
      final response = await supabase
          .from(attendanceTable)
          .select()
          .eq('club_id', clubId);

      final data = response as List<dynamic>;

      final attendeesList = (data)
          .map(
            (e) => Attendance.fromJson(e),
      )
          .toList();

      return attendeesList;
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }
}
