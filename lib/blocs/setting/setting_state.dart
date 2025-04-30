part of 'setting_bloc.dart';

// ignore: must_be_immutable
class SettingState extends BlocState {
  /// Grades
  final List<Grade>? gradeLists;
  final bool? isFetchingGrades;

  /// Club Locations
  final List<Location>? clubLocations;
  final bool? isFetchingClubLocations;

  /// FetchingAllStudentsOfClub
  final bool? isFetchingStudents;
  final List<Student>? students;
  final List<Attendance>? allAttendeesData;
  final List<LessonSchedule>? allLessonSchedulesOfSelectedClub;
  String? sortedColumn;
  bool? isAscending;

  SettingState({
    this.gradeLists,
    this.isFetchingGrades,
    this.isFetchingStudents,
    this.clubLocations,
    this.isFetchingClubLocations,
    this.students,
    this.allAttendeesData,
    this.allLessonSchedulesOfSelectedClub,
    this.sortedColumn,
    this.isAscending,
  });

  @override
  List<Object?> get props => [
        gradeLists,
        isFetchingGrades,
        isFetchingStudents,
        clubLocations,
        isFetchingClubLocations,
        students,
        allAttendeesData,
        allLessonSchedulesOfSelectedClub,
        sortedColumn,
        isAscending,
      ];

  SettingState copyWith({
    List<Grade>? gradeLists,
    bool? isFetchingGrades,
    bool? isFetchingStudents,
    List<Location>? clubLocations,
    bool? isFetchingClubLocations,
    List<Student>? students,
    List<Attendance>? allAttendeesData,
    List<LessonSchedule>? allLessonSchedulesOfSelectedClub,
    String? sortedColumn,
    bool? isAscending,
  }) {
    return SettingState(
      gradeLists: gradeLists ?? this.gradeLists,
      isFetchingGrades: isFetchingGrades ?? this.isFetchingGrades,
      isFetchingStudents: isFetchingStudents ?? this.isFetchingStudents,
      clubLocations: clubLocations ?? this.clubLocations,
      isFetchingClubLocations:
          isFetchingClubLocations ?? this.isFetchingClubLocations,
      students: students ?? this.students,
      allAttendeesData: allAttendeesData ?? this.allAttendeesData,
      allLessonSchedulesOfSelectedClub: allLessonSchedulesOfSelectedClub ??
          this.allLessonSchedulesOfSelectedClub,
      sortedColumn: sortedColumn ?? this.sortedColumn,
      isAscending: isAscending ?? this.isAscending,
    );
  }

  factory SettingState.initial() {
    return SettingState(
      gradeLists: null,
      isFetchingGrades: false,
      isFetchingStudents: false,
      clubLocations: null,
      isFetchingClubLocations: false,
      students: null,
      allAttendeesData: null,
      allLessonSchedulesOfSelectedClub: null,
      sortedColumn: null,
      isAscending: true,
    );
  }

  /// return the first grade from [gradeLists]
  Grade? get firstGrade {
    if (gradeLists != null && gradeLists!.isNotEmpty) {
      return gradeLists!.first;
    }
    return null;
  }
}
