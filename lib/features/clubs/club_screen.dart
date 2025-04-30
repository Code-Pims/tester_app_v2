import 'package:cached_network_image/cached_network_image.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubArguments {
  final Club club;

  const ClubArguments({required this.club});
}

class ClubScreen extends StatefulWidget {
  final Club club;

  ClubScreen({required ClubArguments arguments, super.key})
      : club = arguments.club;

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: DojoDexColors.white,
                  expandedHeight: MediaQuery.of(context).size.height * 0.20,
                  leading: const SizedBox(),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    stretchModes: const [StretchMode.zoomBackground],
                    background: _buildHeader(context),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      BlocBuilder<ClubBloc, ClubState>(
                        buildWhen: (previous, current) => previous != current,
                        builder: (context, state) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.club.title ?? "Unknown",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.club.description ?? "",
                                  style: context.textTheme.bodyMedium!.copyWith(
                                    color: DojoDexColors.secondaryText,
                                  ),
                                ),
                                const Divider(
                                  color: DojoDexColors.gray5,
                                  height: 36.0,
                                ),
                                _buildMoreInfo(
                                  Icons.location_on_outlined,
                                  widget.club.primaryAddress ?? "",
                                ),
                                _buildMoreInfo(
                                  Icons.email_outlined,
                                  widget.club.email ?? "",
                                  onTap: () async {
                                    if (widget.club.email == null) {
                                      return;
                                    }
                                    final emailLaunchUri = Uri(
                                      scheme: 'mailto',
                                      path: widget.club.email,
                                    );
                                    if (await canLaunchUrl(emailLaunchUri)) {
                                      await launchUrl(emailLaunchUri);
                                    }
                                  },
                                ),
                                _buildMoreInfo(
                                  Icons.language,
                                  widget.club.website ?? "None",
                                  onTap: () async {
                                    if (widget.club.website == null) {
                                      return;
                                    }
                                    final websiteLaunchUri =
                                        Uri.parse(widget.club.website ?? "");
                                    if (await canLaunchUrl(websiteLaunchUri)) {
                                      launchUrl(websiteLaunchUri);
                                    }
                                  },
                                ),
                                const SizedBox(height: 48),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
              clipBehavior: Clip.none,
            ),
          ],
        ));
  }

  Widget _buildMoreInfo(IconData icon, String text, {Function()? onTap}) {
    if (text == "") {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Icon(
                icon,
                color: DojoDexColors.secondary,
                size: 35,
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DojoDexColors.secondaryText,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double spacing = 4.0;
    var photoUrls = [
      widget.club.imageurl ?? "",
    ];
    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          physics: const ClampingScrollPhysics(),
          itemCount: photoUrls.length,
          pageSnapping: true,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: photoUrls[index],
            );
          },
        ),
        IgnorePointer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0x00000000),
                  Color(0x55000000),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 0,
          right: 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SmoothPageIndicator(
                controller: pageController,
                count: photoUrls.length,
                effect: SlideEffect(
                  spacing: spacing,
                  radius: 10.0,
                  dotWidth: (width / photoUrls.length) - (spacing * 2),
                  dotHeight: 5.0,
                  dotColor: Colors.white54,
                  activeDotColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 36.0,
          left: 20.0,
          child: CircleShapeButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () async {
              sl<RouteHelper>().popToPreviousPage();
            },
            iconColor: DojoDexColors.primaryText,
            backgroundColor: DojoDexColors.white.withValues(alpha: 0.3),
            size: 40,
          ),
        )
      ],
    );
  }
}
