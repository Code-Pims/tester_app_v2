import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_common/ui/app_colors.dart';
import 'package:dojodex_instructor/blocs/setting/setting_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/common/utils/custom_functions.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/lesson_schedule/create_or_update_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:shimmer/shimmer.dart';

class LessonScheduleCard extends StatelessWidget {
  final LessonSchedule lessonSchedule;

  const LessonScheduleCard({
    super.key,
    required this.lessonSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final grades = context.read<SettingBloc>().state.gradeLists;

    sl<Logger>().i('lessonSchedule: $lessonSchedule');

    final minimumGrade =
        findGradeByValue(grades ?? [], lessonSchedule.minGrade.toString());
    final maximumGrade =
        findGradeByValue(grades ?? [], lessonSchedule.maxGrade.toString());

    return Card(
      child: GestureDetector(
        onTap: () {
          sl<RouteHelper>().showCreateScheduleScreen(
            arguments: CreateOrUpdateScheduleArguments(
              lessonSchedule: lessonSchedule,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: DojoDexColors.white,
            border: Border.all(
              color: DojoDexColors.gray4,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      /// Day week name,
                      lessonSchedule.dayName,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      lessonSchedule.className ?? '',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      lessonSchedule.locationName ?? '',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      lessonSchedule.clubAddress ?? '',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled),
                        const SizedBox(width: 4.0),
                        Text(
                          "${lessonSchedule.formattedStartTime12.format(context)} - ${lessonSchedule.formattedEndTime12.format(context)}",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: DojoDexColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Chip
              Positioned(
                top: 14,
                right: 14,
                child: minimumGrade?.name != null && maximumGrade?.name != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        decoration: BoxDecoration(
                          color: DojoDexColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${minimumGrade!.name} - ${maximumGrade!.name}',
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: DojoDexColors.primaryText),
                        ),
                      )
                    : buildShimmerGradeRange(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildShimmerGradeRange() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white, // Background color for shimmer
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 12, // Adjust height as needed
          width: 80, // Adjust width as needed
          color: Colors.white, // Placeholder shimmer block
        ),
      ),
    );
  }
}
