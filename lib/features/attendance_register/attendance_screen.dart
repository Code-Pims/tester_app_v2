// ignore_for_file: use_build_context_synchronously

import 'package:dojodex_instructor/blocs/attendance/attendance_bloc.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart' as club;
import 'package:dojodex_instructor/blocs/lesson/lesson_bloc.dart';
import 'package:dojodex_instructor/blocs/setting/setting_bloc.dart';
import 'package:dojodex_instructor/common/widgets/headers.dart';
import 'package:dojodex_instructor/features/attendance_register/attendance_filters.dart';
import 'package:dojodex_instructor/features/attendance_register/attendance_table.dart';
import 'package:dojodex_instructor/features/attendance_register/selected_class_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late SettingBloc settingsBloc;
  late bool showAllStudent;

  @override
  void initState() {
    showAllStudent = false;
    context.read<LessonBloc>().add(const FetchSchedules());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DojoDexHeaders.mainAppBar(),

      /// Save button
      floatingActionButton: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (!state.hasChanges) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: () {
              context.read<AttendanceBloc>().add(const UploadAttendance());
            },
            child: const Icon(Icons.save),
          );
        },
      ),
      body: BlocBuilder<club.ClubBloc, club.ClubState>(
          buildWhen: (previous, current) =>
              previous.currentClub != current.currentClub,
          builder: (context, clubState) {
            return BlocConsumer<LessonBloc, LessonState>(
              listener: (context, state) {
                if (state.lessonSchedules?.isEmpty ?? true) {
                  return;
                }

                if (state.selectedLessonSchedule != null &&
                    (state.isFetchingSchedules != null &&
                        !state.isFetchingSchedules!)) {
                  context
                      .read<AttendanceBloc>()
                      .add(FetchClubStudents(state.selectedLessonSchedule!));

                  context
                      .read<AttendanceBloc>()
                      .add(FetchAttendees(state.selectedLessonSchedule!.id!));
                }
              },
              buildWhen: (previous, current) =>
                  previous.lessonSchedules != current.lessonSchedules ||
                  current.isFetchingSchedules != previous.isFetchingSchedules ||
                  previous.selectedLessonSchedule !=
                      current.selectedLessonSchedule,
              builder: (context, state) {
                if (state.isFetchingSchedules ?? false) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
                if (state.nearestLessonSchedule == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        clubState.currentClub == null
                            ? 'Please add a club before creating lesson schedules'
                            : "lesson schedule not added, create a lesson schedule first!",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      SelectedClassDetails(
                        selectedLessonSchedule: state.selectedLessonSchedule ??
                            state.nearestLessonSchedule!,
                      ),
                      AttendanceFilters(
                        showAllStudents: showAllStudent,
                      ),
                      const AttendanceTable(),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
