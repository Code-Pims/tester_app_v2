part of 'lesson_bloc.dart';

abstract class LessonEvent extends BlocEvent {
  const LessonEvent();
}

class FetchSchedules extends LessonEvent {
  const FetchSchedules();

  @override
  List<Object> get props => [];
}

class CreateSchedule extends LessonEvent {
  final LessonSchedule lessonSchedule;

  const CreateSchedule(this.lessonSchedule);

  @override
  List<Object> get props => [lessonSchedule];
}

class UpdateSchedule extends LessonEvent {
  final LessonSchedule lessonSchedule;

  const UpdateSchedule(this.lessonSchedule);

  @override
  List<Object> get props => [lessonSchedule];
}

class DeleteSchedule extends LessonEvent {
  final int lessonScheduleID;

  const DeleteSchedule(this.lessonScheduleID);

  @override
  List<Object> get props => [lessonScheduleID];
}

class ChangeLessonSchedule extends LessonEvent {
  final LessonSchedule selectedLessonSchedule;

  const ChangeLessonSchedule(this.selectedLessonSchedule);

  @override
  List<Object> get props => [selectedLessonSchedule];
}


