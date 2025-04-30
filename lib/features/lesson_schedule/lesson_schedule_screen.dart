import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_instructor/blocs/lesson/lesson_bloc.dart';
import 'package:dojodex_instructor/blocs/setting/setting_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/lesson_schedule/create_or_update_schedule_screen.dart';
import 'package:dojodex_instructor/features/lesson_schedule/lesson_schedule_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class LessonScheduleScreen extends StatefulWidget {
  const LessonScheduleScreen({super.key});

  @override
  State<LessonScheduleScreen> createState() => _LessonScheduleScreenState();
}

class _LessonScheduleScreenState extends State<LessonScheduleScreen> {
  late SettingBloc settingsBloc;
  late LessonBloc lessonBloc;

  @override
  void initState() {
    settingsBloc = context.read<SettingBloc>();
    settingsBloc.add(const FetchGrades());

    lessonBloc = context.read<LessonBloc>();
    lessonBloc.add(const FetchSchedules());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Schedule'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sl<RouteHelper>().showCreateScheduleScreen(
            arguments: const CreateOrUpdateScheduleArguments(
              lessonSchedule: LessonSchedule(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        buildWhen: (previous, current) =>
            previous.lessonSchedules != current.lessonSchedules,
        builder: (context, state) {
          if (state.isFetchingSchedules ?? false) {
            return buildShimmerCard();
          }
          if (state.lessonSchedules == null) {
            return buildShimmerCard();
          } else {
            if (state.lessonSchedules!.isEmpty) {
              return const Center(
                child: Text(
                  'You don\'t have a lesson schedule added, create a lesson schedule first!',
                  textAlign: TextAlign.center,
                ),
              );
            }
          }

          return ListView.builder(
            itemCount: state.lessonSchedules!.length,
            itemBuilder: (context, index) {
              final lessonSchedule = state.lessonSchedules![index];
              return LessonScheduleCard(
                lessonSchedule: lessonSchedule,
              );
            },
          );
        },
      ),
    );
  }

  Widget buildShimmerCard() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 160, // Adjust the height as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shimmer for title (Day name)
                        Container(
                          height: 16,
                          width: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4.0),

                        // Shimmer for location
                        Container(
                          height: 14,
                          width: 150,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4.0),
                        // Shimmer for time row
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled,
                                color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Container(
                              height: 12,
                              width: 120,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shimmer for Chip (Grade Range)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        height: 12,
                        width: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
