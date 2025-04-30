import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_common/ui/widgets/images/dojodex_club_image.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart' as club;
import 'package:dojodex_instructor/blocs/lesson/lesson_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwitchClubBottomSheet extends StatefulWidget {
  const SwitchClubBottomSheet({super.key});

  @override
  State<SwitchClubBottomSheet> createState() => _SwitchClubBottomSheetState();
}

class _SwitchClubBottomSheetState extends State<SwitchClubBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: Wrap(
        children: [
          BlocBuilder<club.ClubBloc, club.ClubState>(
            builder: (context, state) {
              return BlocBuilder<LessonBloc, LessonState>(
                builder: (context, lessonState) {
                  final club = state.currentClub;
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
                          "Switch Club",
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildCurrentClub(club),
                      const Divider(
                        thickness: 1,
                        color: DojoDexColors.gray4,
                      ),
                      _maybeBuildListOfClubs(state, lessonState),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _maybeBuildListOfClubs(club.ClubState state, LessonState lessonState) {
    if (state.clubs == null) {
      return const SizedBox();
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.clubs!.length,
      itemBuilder: (context, index) {
        final selectedClub = state.clubs![index];

        if (selectedClub == state.currentClub) {
          return const SizedBox();
        }

        return ListTile(
          selected: false,
          leading: ClubImage(
            clubImage: selectedClub.imageurl,
            size: 60,
          ),
          title: Text(selectedClub.title ?? ''),
          onTap: () {
            context
                .read<club.ClubBloc>()
                .add(club.SwitchClub(club: selectedClub, context: context));

            lessonState.selectedLessonSchedule = null;

            Navigator.pop(context);
          },
        );
      },
    );
  }

  Column _buildCurrentClub(Club? club) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: ClubImage(
            clubImage: club?.imageurl,
            size: 60,
          ),
          title: Text(club?.title ?? ''),
          trailing: const CircleShapeButton(
            icon: Icons.check,
            size: 30,
            backgroundColor: DojoDexColors.success,
            iconColor: DojoDexColors.white,
          ),
        ),
      ],
    );
  }
}
