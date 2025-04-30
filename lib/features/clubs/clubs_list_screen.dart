// ignore_for_file: use_build_context_synchronously

import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/ui/widgets/images/dojodex_club_image.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/blocs/setting/setting_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/common/widgets/app_drawer.dart';
import 'package:dojodex_instructor/common/widgets/headers.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_instructor/features/student_lists/student_lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:logger/web.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../env/env.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen>
    with SingleTickerProviderStateMixin {
  late RefreshController _refreshController;
  late bool isRefreshing;
  late SettingBloc settingsBloc;

  @override
  void initState() {
    context.read<ClubBloc>().add(const FetchClubs());
    context.read<SettingBloc>().add(const FetchClubLocations());

    isRefreshing = false;
    _refreshController = RefreshController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DojoDexHeaders.mainAppBar(isDrawerVisible: true),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final websiteLaunchUri =
              Uri.parse("${EnvValues.webBaseUrl}/dashboard");

          if (await canLaunchUrl(websiteLaunchUri)) {
            await launchUrl(websiteLaunchUri);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        header: const WaterDropHeader(),
        enablePullDown: true,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DojoDexHeaders.mainHeader(
                title: Text(
                  "My Clubs",
                  style: context.textTheme.headlineMedium?.copyWith(),
                ),
              ),
              const SizedBox(height: 16.0),
              BlocConsumer<ClubBloc, ClubState>(
                listenWhen: (previous, current) =>
                    previous.isFetchingClubs != current.isFetchingClubs,
                listener: (context, state) {
                  sl<Logger>().i(state.isFetchingClubs);
                  if ((state.isFetchingClubs ?? false)) {
                    _refreshController.requestRefresh();
                  }
                  if (!(state.isFetchingClubs ?? false)) {
                    _refreshController.refreshCompleted();
                  }
                },
                buildWhen: (previous, current) =>
                    previous.clubs != current.clubs,
                builder: (context, state) {
                  if (state.isFetchingClubs ?? false) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if ((state.clubs?.isEmpty ?? true) || state.clubs == null) {
                    return _buildEmptyState(context);
                  }
                  return Column(
                    children: state.clubs
                            ?.map((club) => _buildClubItem(club))
                            .toList() ??
                        [],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRefresh() async {
    context.read<ClubBloc>().add(const FetchClubs());
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  Center _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/lotties/empty_document.json",
            repeat: false,
          ),
          Text(
            "You don't have a club yet.",
            style: context.textTheme.headlineSmall?.copyWith(
              color: DojoDexColors.gray1,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            "Please add a club to get started.",
            style: TextStyle(
              color: DojoDexColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showClubStudentLists(Club? club) {
    if (club == null) {
      return;
    }
    sl<RouteHelper>().showClubStudentLists(
      StudentListsArguments(club: club),
    );
  }

  InkWell _buildClubItem(Club? club) {
    return InkWell(
      onTap: () {
        _showClubStudentLists(club);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            _buildImageAndTitleAndDescription(club, context),
            _maybeBuildPrimaryAddress(club, context),
          ],
        ),
      ),
    );
  }

  Widget _maybeBuildPrimaryAddress(Club? club, BuildContext context) {
    if (club?.primaryAddress == null ||
        club?.primaryAddress?.isEmpty == true ||
        club?.primaryAddress == '') {
      return const SizedBox();
    }
    return Column(
      children: [
        const Divider(
          color: DojoDexColors.gray5,
          height: 24.0,
        ),
        Row(
          children: [
            const Expanded(
              child: Icon(
                Icons.location_on_outlined,
                color: DojoDexColors.primary,
              ),
            ),
            Expanded(
              flex: 7,
              child: Text(
                club?.primaryAddress ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: DojoDexColors.secondaryText),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row _buildImageAndTitleAndDescription(Club? club, BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _maybeBuildImage(club),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                club?.title ?? '',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8.0),
              Text(
                club?.description ?? '',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Expanded(
          child: IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: DojoDexColors.gray4,
              size: 16,
            ),
            onPressed: () {
              _showClubStudentLists(club);
            },
          ),
        ),
      ],
    );
  }

  Widget _maybeBuildImage(Club? club) {
    return ClubImage(
      clubImage: club?.imageurl,
      size: 80,
    );
  }
}
