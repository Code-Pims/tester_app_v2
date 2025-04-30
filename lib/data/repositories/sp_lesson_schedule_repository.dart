import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_instructor/common/architecture/supabase_base_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLessonScheduleRepository extends SupabaseBaseRepository {
  SupabaseLessonScheduleRepository({required SupabaseClient supabase})
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

  Future<void> createLessonSchedule(
      {required LessonSchedule lessonSchedule}) async {
    try {
      await supabase.from(lessonScheduleTable).insert(
            lessonSchedule.toJson()
              ..remove('id')
              ..remove('created_at'),
          );
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<void> updateLessonSchedule(
      {required LessonSchedule lessonSchedule}) async {
    debugPrint("check lessonSchedule data  ==>  $lessonSchedule");

    try {
      await supabase.from(lessonScheduleTable).update({
        ...lessonSchedule.toJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', lessonSchedule.id!);
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
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
}
