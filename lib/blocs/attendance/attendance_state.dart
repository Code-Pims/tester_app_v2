part of 'attendance_bloc.dart';

class AttendanceState extends BlocState {
  /// Local list of ticked attendees
  final List<Attendance>? tickedAttendees;

  ///
  final List<Student>? students;

  /// List from the server
  final List<Attendance>? listOfAttendees;
  final bool? isFetchingStudents;
  final bool? isFetchingAttendees;
  final bool? isUploadingAttendance;

  const AttendanceState({
    this.tickedAttendees,
    this.students,
    this.listOfAttendees,
    this.isFetchingStudents,
    this.isFetchingAttendees,
    this.isUploadingAttendance,
  });

  @override
  List<Object?> get props => [
        tickedAttendees,
        students,
        listOfAttendees,
        isFetchingStudents,
        isFetchingAttendees,
        isUploadingAttendance,
      ];

  AttendanceState copyWith({
    List<Attendance>? tickedAttendees,
    List<Student>? students,
    List<Attendance>? listOfAttendees,
    bool? isFetchingStudents,
    bool? isFetchingAttendees,
    bool? isUploadingAttendance,
  }) {
    return AttendanceState(
      students: students ?? this.students,
      listOfAttendees: listOfAttendees ?? this.listOfAttendees,
      isFetchingStudents: isFetchingStudents ?? this.isFetchingStudents,
      isFetchingAttendees: isFetchingAttendees ?? this.isFetchingAttendees,
      isUploadingAttendance:
          isUploadingAttendance ?? this.isUploadingAttendance,
      tickedAttendees: tickedAttendees ?? this.tickedAttendees,
    );
  }

  factory AttendanceState.initial() {
    return const AttendanceState(
      students: null,
      listOfAttendees: null,
      isFetchingStudents: false,
      isFetchingAttendees: false,
      isUploadingAttendance: false,
      tickedAttendees: null,
    );
  }

  List<String> get tableColumns => [
        'Name',
        'Age',
        'Grade',
      ];

  /// is in the list of ticked attendees
  /// combination of [tickedAttendees] and [listOfAttendees]
  /// refer to [tickedAttendeesToday]
  bool isTicked(int studentId) {
    return tickedAttendeesToday.any((element) {
      return element.studentId == studentId;
    });
  }

  /// ticked attendees today
  /// it should be the list of [tickedAttendees] and [presentStudentsToday]
  /// use [Set] to avoid duplicates
  /// it should return List<Attendance>
  List<Attendance> get tickedAttendeesToday {
    final Set<Attendance> attendeesSet = {};

    if (tickedAttendees != null) {
      attendeesSet.addAll(tickedAttendees!);
    }

    attendeesSet.addAll(presentStudentsToday);

    return attendeesSet.toList();
  }

  /// all attendees data
  /// it should be the list of [tickedAttendees] and [listOfAttendees]
  /// use [Set] to avoid duplicates
  /// it should return List<Attendance>
  List<Attendance> get allAttendees {
    final Set<Attendance> attendeesSet = {};

    if (tickedAttendees != null) {
      attendeesSet.addAll(tickedAttendees!);
    }

    if (listOfAttendees != null) {
      attendeesSet.addAll(listOfAttendees!);
    }

    return attendeesSet.toList();
  }

  /// track the changes in the list of ticked attendees and list of attendees
  bool get hasChanges {
    if (tickedAttendees == null || listOfAttendees == null) {
      return false;
    }

    return !listEquals(
      tickedAttendees!.map((e) => e.studentId).toList(),
      listOfAttendees!.map((e) => e.studentId).toList(),
    );
  }

  /// get the students that are present today
  /// this is based on the [listOfAttendee.lastSessionDate] is empty
  /// based on [listOfAttendees]
  /// from the server
  List<Attendance> get presentStudentsToday {
    if (listOfAttendees == null) {
      return [];
    }

    return listOfAttendees!.where((element) {
      return element.lastSessionDate == null;
    }).toList();
  }

  /// get the students that are present last session
  /// this is based on the [listOfAttendee.lastSessionDate] is not empty
  /// based on [listOfAttendees]
  List<Attendance> get presentStudentsLastSession {
    if (listOfAttendees == null) {
      return [];
    }

    return listOfAttendees!.where((element) {
      return element.lastSessionDate != null;
    }).toList();
  }

  /// get method if the student is present today
  /// use [presentStudentsToday] to map the student id
  bool isPresentToday(int studentId) {
    return presentStudentsToday.any((element) {
      return element.studentId == studentId;
    });
  }

  /// get method if the student is present
  /// it should return true if the student is present
  /// use [presentStudentsLastSession] to map the student id
  bool isPresentLastSession(int studentId) {
    return presentStudentsLastSession.any((element) {
      return element.studentId == studentId;
    });
  }

  /// compare the ticked attendees and the list of attendees
  /// if there are missing attendees, return the list of missing attendees
  /// these are un-ticked attendees
  List<Attendance> get missingAttendees {
    if (tickedAttendees == null || listOfAttendees == null) {
      return [];
    }

    return listOfAttendees!.where((element) {
      return !tickedAttendees!.any((e) => e.studentId == element.studentId);
    }).toList();
  }
}
