import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dojodex_common/models/attendance/attendance.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_common/models/location/location.dart';
import 'package:dojodex_common/models/student/student.dart';
import 'package:dojodex_instructor/common/services/club_service.dart';
import 'package:dojodex_instructor/common/services/token_service.dart';
import 'package:dojodex_instructor/data/database/database_service.dart';
import 'package:dojodex_instructor/data/repositories/setting_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/dojodex_architecture.dart';
import 'package:dojodex_common/models/grades/grade.dart';
import 'package:logger/web.dart';

import '../../data/repositories/sp_attendance_repository.dart';
import '../../data/repositories/sp_lesson_schedule_repository.dart';

part 'setting_event.dart';

part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SettingRepository settingRepository;
  final SupabaseAttendanceRepository attendanceRepository;
  final SupabaseLessonScheduleRepository lessonRepository;

  SettingBloc()
      : settingRepository = sl<SettingRepository>(),
        attendanceRepository = sl<SupabaseAttendanceRepository>(),
        lessonRepository = sl<SupabaseLessonScheduleRepository>(),
        super(SettingState.initial()) {
    on<FetchGrades>(_onFetchGrades);
    on<FetchClubLocations>(_onFetchClubLocations);
    on<FetchAllStudentsFromClub>(_onFetchAllStudentsFromClub);
    on<Logout>(_onLogout);
  }

  /// close the subscription when the bloc is closed
  @override
  Future<void> close() {
    return super.close();
  }

  FutureOr<void> _onFetchGrades(event, emit) async {
    try {
      emit(state.copyWith(isFetchingGrades: true));
      final grades = await settingRepository.fetchGrades();
      emit(state.copyWith(gradeLists: grades, isFetchingGrades: false));
    } catch (e) {
      emit(state.copyWith(isFetchingGrades: false));
    }
  }

  FutureOr<void> _onLogout(Logout event, Emitter<SettingState> emit) async {
    final tokenService = sl<TokenService>();

    await tokenService.deleteToken();
    await sl<DatabaseService>().deleteAllTables();
  }

  FutureOr<void> _onFetchClubLocations(
    FetchClubLocations event,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(isFetchingClubLocations: true));
    try {
      final currentClub = await sl<ClubService>().getCurrentClub();

      sl<Logger>().i("Current Club: $currentClub");
      if (currentClub == null) {
        emit(state.copyWith(isFetchingClubLocations: false, clubLocations: []));
        return;
      }

      final locations = await settingRepository.fetchClubLocations(
        clubID: currentClub.id.toString(),
      );

      emit(state.copyWith(
        clubLocations: locations,
        isFetchingClubLocations: false,
      ));
    } catch (e) {
      emit(state.copyWith(isFetchingClubLocations: false));
    }
  }

  FutureOr<void> _onFetchAllStudentsFromClub(
    FetchAllStudentsFromClub event,
    Emitter<SettingState> emit,
  ) async {
    /// create a mock list of students
    ///
    emit(state.copyWith(
      isFetchingStudents: true,
    ));
    final currentClub = await sl<ClubService>().getCurrentClub();

    sl<Logger>().i("Current Club: $currentClub");
    if (currentClub == null) {
      emit(state.copyWith(isFetchingStudents: false));
      return;
    }

    final students = await settingRepository.fetchAllStudentsFromSelectedClub(
      currentClub.id!,
    );

    final lessonSchedules = await lessonRepository.fetchMyLessonSchedules(
      clubId: currentClub.id.toString(),
    );

    final allAttendeesData = await attendanceRepository
        .fetchAllAttendeesOfSelectedClub(currentClub.id!);

    emit(state.copyWith(
      allLessonSchedulesOfSelectedClub: lessonSchedules,
      allAttendeesData: allAttendeesData,
      students: students,
      isFetchingStudents: false,
    ));
  }
}
