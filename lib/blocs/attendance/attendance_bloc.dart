import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dojodex_common/dojodex_architecture.dart';
import 'package:dojodex_common/models/attendance/attendance.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_common/models/student/student.dart';
import 'package:dojodex_instructor/common/services/club_service.dart';
import 'package:dojodex_instructor/data/repositories/club_repository.dart';
import 'package:dojodex_instructor/data/repositories/sp_attendance_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

part 'attendance_event.dart';

part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final ClubRepository clubRepository;
  final SupabaseAttendanceRepository attendanceRepository;

  AttendanceBloc()
      : clubRepository = sl<ClubRepository>(),
        attendanceRepository = sl<SupabaseAttendanceRepository>(),
        super(AttendanceState.initial()) {
    /// States
    on<ToggleStudent>(_onToggleStudent);

    /// Repostory
    on<FetchClubStudents>(_onFetchClubStudents);
    on<FetchAttendees>(_onFetchAttendees);
    on<UploadAttendance>(_onUploadAttendance);
  }

  FutureOr<void> _onFetchClubStudents(
    FetchClubStudents event,
    Emitter<AttendanceState> emit,
  ) async {
    /// create a mock list of students
    ///
    emit(state.copyWith(
      isFetchingStudents: true,
    ));

    int? currentClubId;

    debugPrint("check event.lessonSchedule   ==>   ${event.lessonSchedule}");

    if (event.lessonSchedule != null) {
      if (event.lessonSchedule!.clubID == null) {
        return;
      } else {
        currentClubId = event.lessonSchedule!.clubID;
      }
    } else {
      final clubService = sl<ClubService>();
      var currentClub = await clubService.getCurrentClub();

      if (currentClub == null) {
        return;
      } else {
        currentClubId = currentClub.id;
      }
    }

    final students = await clubRepository.fetchClubStudents(
      currentClubId!,
      lessonSchedule: event.lessonSchedule,
    );

    emit(state.copyWith(
      students: students,
      isFetchingStudents: false,
    ));
    // add(FetchAttendees(event.lessonSchedID));
  }

  FutureOr<void> _onFetchAttendees(
    FetchAttendees event,
    Emitter<AttendanceState> emit,
  ) async {
    /// create a mock list of attendees
    emit(state.copyWith(
      isFetchingAttendees: true,
    ));

    final attendees = await attendanceRepository.fetchAttendees(event.schedID);

    emit(
      state.copyWith(
        listOfAttendees: attendees,
        isFetchingAttendees: false,
      ),
    );
  }

  FutureOr<void> _onUploadAttendance(
    UploadAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(
      state.copyWith(
        isUploadingAttendance: true,
      ),
    );

    final tickedAttendees = state.tickedAttendeesToday;

    final attendees = tickedAttendees.map((e) {
      return Attendance(
        studentId: e.studentId,
        clubID: e.clubID,
        lessonschedID: tickedAttendees.first.lessonschedID,
      );
    }).toList();

    try {
      sl<Logger>().i('Inserting multiple attendees');
      await attendanceRepository.insertMultipleAttendees(
        attendees: attendees,
      );
      emit(
        state.copyWith(
          isUploadingAttendance: false,
        ),
      );
    } catch (e) {
      sl<Logger>().e(e);
      emit(
        state.copyWith(
          isUploadingAttendance: false,
        ),
      );
    }
  }

  FutureOr<void> _onToggleStudent(
    ToggleStudent event,
    Emitter<AttendanceState> emit,
  ) async {
    final clubService = sl<ClubService>();
    final currentClub = await clubService.getCurrentClub();

    final tickedAttendeesToday = state.tickedAttendeesToday;
    final listOfAttendees = state.listOfAttendees ?? [];
    final studentId = event.studentId;

    Attendance attendance = Attendance(
      studentId: studentId,
      clubID: currentClub!.id,
      lessonschedID: event.lessonScheduleId,
    );

    final isInTheList =
        tickedAttendeesToday.any((element) => element.studentId == studentId);

    if (isInTheList) {
      /// Do not remove the student if the last session date is not null
      final newListOfAttendees = listOfAttendees
          .where((element) =>
              element.studentId != studentId || element.lastSessionDate != null)
          .toList();

      final newTickedAttendees = tickedAttendeesToday
          .where((element) =>
              element.studentId != studentId || element.lastSessionDate != null)
          .toList();

      emit(
        state.copyWith(
          tickedAttendees: newTickedAttendees,
          listOfAttendees: newListOfAttendees,
        ),
      );
    } else {
      final newTickedAttendees = [
        ...tickedAttendeesToday,
        attendance,
      ];
      emit(
        state.copyWith(
          tickedAttendees: newTickedAttendees,
        ),
      );
    }

    sl<Logger>().i(state.allAttendees);
  }
}
