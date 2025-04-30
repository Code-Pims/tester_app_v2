import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/blocs/lesson/lesson_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/attendance/attendance_bloc.dart';

// ignore: must_be_immutable
class AttendanceFilters extends StatefulWidget {
  bool showAllStudents;

  AttendanceFilters({super.key, this.showAllStudents = false});

  @override
  State<AttendanceFilters> createState() => _AttendanceFiltersState();
}

class _AttendanceFiltersState extends State<AttendanceFilters> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Switch(
                    value: widget.showAllStudents,
                    onChanged: (value) {
                      setState(() {
                        widget.showAllStudents = value;
                      });

                      if (widget.showAllStudents) {
                        context
                            .read<AttendanceBloc>()
                            .add(const FetchClubStudents(null));
                      } else {
                        LessonState lessonState =
                            context.read<LessonBloc>().state;

                        context.read<AttendanceBloc>().add(FetchClubStudents(
                            lessonState.selectedLessonSchedule));
                      }
                    },
                    activeColor: DojoDexColors.primary,
                    inactiveThumbColor: DojoDexColors.gray4,
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(WidgetState.disabled)) {
                          return DojoDexColors.gray4;
                        }
                        if (states.contains(WidgetState.selected)) {
                          return DojoDexColors.primary;
                        }
                        return DojoDexColors.gray4;
                      },
                    ),
                  ),
                  Text(
                    'Show All Students',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: DojoDexColors.primaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
