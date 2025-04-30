// ignore_for_file: use_build_context_synchronously

import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/ui/widgets/images/dojodex_club_image.dart';
import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/blocs/setting/setting_bloc.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/common/widgets/headers.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    context.read<SettingBloc>().add(const FetchClubLocations());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DojoDexHeaders.mainAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ListView(
            children: [
              DojoDexHeaders.mainHeader(
                title: Text(
                  "Settings",
                  style: context.textTheme.headlineMedium?.copyWith(),
                ),
              ),
              Column(
                children: [
                  /// Build Profile image
                  BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      if (state.user == null) {
                        return const SizedBox();
                      }

                      if (!(state.user?.isAuthenticated ?? false)) {
                        return const SizedBox();
                      }

                      return Column(
                        children: [
                          BlocBuilder<ClubBloc, ClubState>(
                            builder: (context, clubState) {
                              final club = clubState.currentClub;
                              if (club == null) {
                                return const SizedBox();
                              }
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 24.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          ClubImage(
                                            clubImage: club.imageurl,
                                            size: 60,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                club.title ?? "",
                                                style: context
                                                    .textTheme.bodyMedium,
                                              ),
                                              Text(
                                                "Current Club",
                                                style: context
                                                    .textTheme.bodySmall!
                                                    .copyWith(
                                                  color: DojoDexColors.gray3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  /// Build Profile image
                  // _buildSwitchClubSection(),
                  BlocBuilder<ClubBloc, ClubState>(builder: (context, state) {
                    if (state.currentClub == null) {
                      return const SizedBox();
                    }
                    return _buildListTileTitle(context,
                        title: 'Attendance Module');
                  }),
                  // _buildListTileItem(
                  //   'Locations',
                  //   Icons.location_on,
                  //   Colors.blue[200],
                  //   Colors.white,
                  //   () async {},
                  // ),
                  BlocBuilder<ClubBloc, ClubState>(
                    builder: (context, state) {
                      if (state.currentClub == null) {
                        return const SizedBox();
                      }
                      return _buildListTileItem(
                        'Lesson Schedule',
                        Icons.schedule_outlined,
                        Colors.purple[200],
                        Colors.white,
                        () async {
                          sl<RouteHelper>().showLessonScheduleScreen();
                        },
                      );
                    },
                  ),
                  BlocBuilder<ClubBloc, ClubState>(
                    builder: (context, state) {
                      if (state.currentClub == null) {
                        return const SizedBox();
                      }
                      return _buildListTileItem(
                        'Attendance Report',
                        Icons.data_thresholding_outlined,
                        DojoDexColors.primary.withValues(alpha: 0.6),
                        Colors.white,
                        () async {
                          sl<RouteHelper>().showAttendanceReportScreen();
                        },
                      );
                    },
                  ),
                  const Divider(
                    color: DojoDexColors.gray5,
                  ),
                  _buildListTileItem(
                    'Logout',
                    Icons.logout,
                    Colors.green[200],
                    Colors.white,
                    () async {
                      context.read<SettingBloc>().add(const Logout());
                    },
                  ),
                  const Divider(),
                  _buildListTileItem(
                    'Delete Account',
                    Icons.delete,
                    Colors.red[200],
                    Colors.white,
                    () async {
                      _launchUrl(Uri.parse('https://dojodex.org/delete-me/'));
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  ListTile _buildListTileTitle(BuildContext context, {String? title}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      tileColor: Colors.transparent,
      title: Text(
        title ?? "",
        style: context.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  ListTile _buildListTileItem(
    String label,
    IconData icon,
    Color? backgroundColor,
    Color? iconColor,
    Function()? onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: backgroundColor ?? Colors.amber[200],
            child: Icon(
              icon,
              color: iconColor ?? DojoDexColors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 15,
      ),
    );
  }
}
