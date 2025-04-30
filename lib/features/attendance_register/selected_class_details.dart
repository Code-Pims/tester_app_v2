import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/features/attendance_register/switch_class_name_sheet.dart';
import 'package:flutter/material.dart';

class SelectedClassDetails extends StatefulWidget {
  final LessonSchedule selectedLessonSchedule;

  const SelectedClassDetails({super.key, required this.selectedLessonSchedule});

  @override
  State<SelectedClassDetails> createState() => _SelectedClassDetailsState();
}

class _SelectedClassDetailsState extends State<SelectedClassDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      decoration: const BoxDecoration(
        color: DojoDexColors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.selectedLessonSchedule.className ?? "",
                  style: context.textTheme.titleSmall?.copyWith(
                    color: DojoDexColors.primaryText,
                  ),
                ),
                Text(
                  "${widget.selectedLessonSchedule.locationName ?? ""} | ${getShortDayName(widget.selectedLessonSchedule.dayName)} - ${widget.selectedLessonSchedule.formattedStartTime12.format(context)} - ${widget.selectedLessonSchedule.formattedEndTime12.format(context)}",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: DojoDexColors.primaryText,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          CircleShapeButton(
            icon: Icons.arrow_drop_down,
            backgroundColor: DojoDexColors.gray6,
            size: 30,
            onPressed: () {
              /// bottom sheet to switch club
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const SwitchClassNameSheet();
                },
              );
            },
          ),
        ],
      ),
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
