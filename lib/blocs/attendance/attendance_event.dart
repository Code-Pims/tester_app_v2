part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends BlocEvent {
  const AttendanceEvent();
}

class FetchClubStudents extends AttendanceEvent {
  final LessonSchedule? lessonSchedule;

  const FetchClubStudents(this.lessonSchedule);

  @override
  List<Object> get props => [lessonSchedule ?? const LessonSchedule()];
}

class FetchAttendees extends AttendanceEvent {
  final int schedID;

  const FetchAttendees(this.schedID);

  @override
  List<Object> get props => [schedID];
}

class UploadAttendance extends AttendanceEvent {
  const UploadAttendance();

  @override
  List<Object> get props => [];
}

class ToggleStudent extends AttendanceEvent {
  final int studentId;
  final int lessonScheduleId;

  const ToggleStudent(this.studentId, this.lessonScheduleId);

  @override
  List<Object> get props => [studentId, lessonScheduleId];
}

class MapStudentToAttendance extends AttendanceEvent {
  const MapStudentToAttendance();

  @override
  List<Object> get props => [];
}
