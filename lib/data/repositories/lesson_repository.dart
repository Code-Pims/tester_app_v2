import 'package:dio/dio.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_instructor/common/architecture/base_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:logger/web.dart';

class LessonRepository extends BaseRepository {
  LessonRepository({required Dio dio}) : super(dio);

  Future<List<LessonSchedule>> fetchLessonSchedules({String? clubID}) async {
    String url = "/wcra/v1/lessonschedule/list?clubID=$clubID";

    sl<Logger>().i("Fetching lesson schedules");
    try {
      final response = await dio.get(url);

      final lessonSchedules = (response.data['data'] as List).map((e) {
        return LessonSchedule.fromJson(e);
      }).toList();

      return lessonSchedules;
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<void> createLessonSchedule({
    required LessonSchedule lessonSchedule,
  }) async {
    String url = "/wcra/v1/lessonschedule/add";

    try {
      await dio.post(
        url,
        data: lessonSchedule.toJson(),
      );
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<void> updateLessonSchedule({
    required LessonSchedule lessonSchedule,
  }) async {
    String url = "/wcra/v1/lessonschedule/edit";

    sl<Logger>().i({"Updating lesson schedule", lessonSchedule.toJson()});
    try {
      await dio.post(
        url,
        data: lessonSchedule.toJson(),
      );
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<void> deleteLessonSchedule({
    required int lessonScheduleID,
  }) async {
    String url = "/wcra/v1/lessonschedule/delete";

    sl<Logger>().i({"Deleting lesson schedule", lessonScheduleID});
    try {
      await dio.post(
        url,
        data: {"schedID": lessonScheduleID},
      );
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }
}
