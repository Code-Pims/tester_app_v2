import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_common/ui/widgets/images/dojodex_club_image.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/features/settings/switch_club_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarWidget extends StatelessWidget {
  final bool? isDrawerVisible;

  const AppBarWidget({super.key, this.isDrawerVisible});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClubBloc, ClubState>(
      builder: (context, clubState) {
        final club = clubState.currentClub;
        if (club == null) {
          return const SizedBox();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                ClubImage(
                  clubImage: club.imageurl,
                  size: 40,
                  isGreyScale: false,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.title ?? "",
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: DojoDexColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 10),
            CircleShapeButton(
              icon: Icons.arrow_drop_down,
              backgroundColor: DojoDexColors.gray5,
              size: 30,
              onPressed: () {
                /// bottom sheet to switch club
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return const SwitchClubBottomSheet();
                  },
                );
              },
            ),
            if (isDrawerVisible ?? false) const SizedBox(width: 56),
          ],
        );
      },
    );
  }
}
