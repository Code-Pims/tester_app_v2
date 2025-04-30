part of 'lesson_bloc.dart';

// ignore: must_be_immutable
class LessonState extends BlocState {
  final List<LessonSchedule>? lessonSchedules;
  LessonSchedule? selectedLessonSchedule;
  final bool? isFetchingSchedules;
  final bool? isCreatingSchedule;
  final bool? isUpdatingSchedule;
  final bool? isDeletingSchedule;

  LessonState({
    this.lessonSchedules,
    this.selectedLessonSchedule,
    this.isFetchingSchedules,
    this.isCreatingSchedule,
    this.isUpdatingSchedule,
    this.isDeletingSchedule,
  });

  @override
  List<Object?> get props => [
        lessonSchedules,
        selectedLessonSchedule,
        isFetchingSchedules,
        isCreatingSchedule,
        isUpdatingSchedule,
        isDeletingSchedule,
      ];

  LessonState copyWith({
    List<LessonSchedule>? lessonSchedules,
    LessonSchedule? selectedLessonSchedule,
    bool? isFetchingSchedules,
    bool? isCreatingSchedule,
    bool? isUpdatingSchedule,
    bool? isDeletingSchedule,
  }) {
    return LessonState(
      lessonSchedules: lessonSchedules ?? this.lessonSchedules,
      selectedLessonSchedule:
          selectedLessonSchedule ?? this.selectedLessonSchedule,
      isFetchingSchedules: isFetchingSchedules ?? this.isFetchingSchedules,
      isCreatingSchedule: isCreatingSchedule ?? this.isCreatingSchedule,
      isUpdatingSchedule: isUpdatingSchedule ?? this.isUpdatingSchedule,
      isDeletingSchedule: isDeletingSchedule ?? this.isDeletingSchedule,
    );
  }

  factory LessonState.initial() {
    return LessonState(
      lessonSchedules: null,
      selectedLessonSchedule: null,
      isFetchingSchedules: false,
      isCreatingSchedule: false,
      isUpdatingSchedule: false,
      isDeletingSchedule: false,
    );
  }

  /// return the days of the week
  List<String> get daysOfWeek => [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

  /// get day name from day index
  String getDayName(int dayIndex) {
    return daysOfWeek[dayIndex];
  }

  /// get day index from day name
  int getDayIndex(String dayName) {
    return daysOfWeek.indexOf(dayName);
  }

  /// nearest lesson schedule
  /// get the nearest sched time from the current time
  /// and from the current date
  /// if there is no schedule for the current day
  /// get the nearest day of the week
  /// from the current date
  /// and the nearest time of the nearest day

  LessonSchedule? get nearestLessonSchedule {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = now;

    // Filter schedules for the current day and start time greater than or equal to now
    final todaySchedules = lessonSchedules
        ?.where((element) =>
            element.dayIndex == currentDay &&
            element.startTime != null &&
            element.startTime!.isAfter(currentTime))
        .toList();

    if (todaySchedules != null && todaySchedules.isNotEmpty) {
      // Sort schedules by start time
      todaySchedules.sort((a, b) => a.startTime!.compareTo(b.startTime!));
      return todaySchedules.first;
    }

    // If no schedules for today, find the nearest schedule for the upcoming days
    for (int i = 1; i <= 7; i++) {
      final nextDay = (currentDay + i) % 7;
      final nextDaySchedules = lessonSchedules
          ?.where((element) =>
              element.dayIndex == nextDay && element.startTime != null)
          .toList();

      if (nextDaySchedules != null && nextDaySchedules.isNotEmpty) {
        // Sort schedules by start time
        nextDaySchedules.sort((a, b) => a.startTime!.compareTo(b.startTime!));
        return nextDaySchedules.first;
      }
    }

    return null;
  }
}
