import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/lesson/lesson_bloc.dart';

class SwitchClassNameSheet extends StatefulWidget {
  const SwitchClassNameSheet({super.key});

  @override
  State<SwitchClassNameSheet> createState() => _SwitchClassNameSheetState();
}

class _SwitchClassNameSheetState extends State<SwitchClassNameSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          LessonSchedule? selectedClass;

          if (state.selectedLessonSchedule == null) {
            state.selectedLessonSchedule = state.nearestLessonSchedule;
            selectedClass = state.selectedLessonSchedule;
          } else {
            selectedClass = state.selectedLessonSchedule;
          }

          const edgeInsets = EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          );
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: edgeInsets,
                child: Text(
                  "Switch Class",
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildCurrentClass(selectedClass),
              const Divider(
                thickness: 0.5,
                color: DojoDexColors.gray4,
              ),
              const SizedBox(
                height: 10,
              ),
              _maybeBuildListOfClubs(state),
            ],
          );
        },
      ),
    );
  }

  Widget _maybeBuildListOfClubs(LessonState state) {
    if (state.lessonSchedules == null) {
      return const SizedBox();
    }
    return Expanded(
      child: ListView.builder(
        itemCount: state.lessonSchedules!.length,
        itemBuilder: (context, index) {
          final classObject = state.lessonSchedules![index];

          if (state.selectedLessonSchedule != null &&
              (classObject == state.selectedLessonSchedule!)) {
            return const SizedBox();
          }

          return GestureDetector(
            onTap: () {
              context
                  .read<AttendanceBloc>()
                  .add(FetchClubStudents(classObject));
              context.read<LessonBloc>().add(ChangeLessonSchedule(classObject));
              Navigator.pop(context);
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classObject.className ?? '',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: DojoDexColors.primaryText,
                        ),
                      ),
                      Text(
                        classObject.locationName ?? '',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: DojoDexColors.primaryText,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Text(
                            "${getShortDayName(classObject.dayName)} - ",
                            style: context.textTheme.bodySmall?.copyWith(
                              color: DojoDexColors.primaryText,
                            ),
                          ),
                          const Icon(
                            Icons.access_time_filled,
                            size: 14,
                            color: DojoDexColors.gray4,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            "${classObject.formattedStartTime12.format(context)} - ${classObject.formattedEndTime12.format(context)}",
                            style: context.textTheme.bodySmall?.copyWith(
                              color: DojoDexColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (index != state.lessonSchedules!.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      thickness: 0.5,
                      color: DojoDexColors.gray4,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Column _buildCurrentClass(LessonSchedule? selectedClass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedClass!.className ?? '',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: DojoDexColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    selectedClass.locationName ?? '',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: DojoDexColors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: CircleShapeButton(
                icon: Icons.check,
                size: 30,
                backgroundColor: DojoDexColors.success,
                iconColor: DojoDexColors.white,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                "${getShortDayName(selectedClass.dayName)} - ",
                style: context.textTheme.labelSmall?.copyWith(
                  color: DojoDexColors.primaryText,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                "${selectedClass.formattedStartTime12.format(context)} - ${selectedClass.formattedEndTime12.format(context)}",
                style: context.textTheme.labelSmall?.copyWith(
                  color: DojoDexColors.primaryText,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                width: 24,
              ),
              Text(
                "${selectedClass.minAge}/${selectedClass.maxAge}",
                style: context.textTheme.labelMedium?.copyWith(
                  color: DojoDexColors.gray4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                width: 24,
              ),
              Text(
                "${selectedClass.minGrade}/${selectedClass.maxGrade}",
                style: context.textTheme.labelMedium?.copyWith(
                  color: DojoDexColors.gray4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getShortDayName(String fullDayName) {
    Map<String, String> dayMap = {
      "Monday": "Mon",
      "Tuesday": "Tue",
      "Wednesday": "Wed",
      "Thursday": "Thu",
      "Friday": "Fri",
      "Saturday": "Sat",
      "Sunday": "Sun",
    };

    return dayMap[fullDayName] ?? fullDayName;
  }
}
