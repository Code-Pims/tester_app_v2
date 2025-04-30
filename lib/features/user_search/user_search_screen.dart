import 'dart:async';

import 'package:dojodex_common/dojdex_models.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dojodex_common/extensions/text_extension.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  Timer? _debounce;
  String searchValue = '';

  @override
  void initState() {
    final myClubIds = context.read<ClubBloc>().state.myClubIds;
    context
        .read<AuthenticationBloc>()
        .add(FetchSearchableUserIds(myClubIds ?? []));
    searchValue = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          final myClubs = context.read<ClubBloc>().state.myClubIds;
          if (myClubs == null || myClubs.isEmpty) {
            /// The user is not in any clubs
            /// So they are not allowed to search for users
            return _buildNoClubState(context);
          }
          return Column(
            children: [
              /// List of clubs
              Expanded(
                child: BlocBuilder<ClubBloc, ClubState>(
                  builder: (context, state) {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final club in state.clubs ?? <Club>[])
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                sl<RouteHelper>()
                                    .popToPreviousPage(result: club);
                              },
                              child: Chip(
                                label: Text(club.title ?? ''),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                flex: 10,
                child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, authenticationState) {
                    return DojodexPaginationWidget<User>(
                      isLoadingData:
                          authenticationState.isFetchingUser ?? false,
                      // isLoadingPagination: state.isPaginationLoading,
                      onRequest: () {
                        // context.read<ClubBloc>().add(const FetchClubs());
                      },
                      items: authenticationState.searchableUsers ?? [],
                      onSearch: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();

                        _debounce =
                            Timer(const Duration(milliseconds: 500), () {
                          if ((value?.isEmpty ?? true) ||
                              value == null ||
                              value == '') {
                            setState(() {
                              searchValue = '';
                            });
                            context.read<AuthenticationBloc>().add(
                                  const FetchSearchedUsers(null),
                                );
                            return;
                          }

                          setState(() {
                            searchValue = value;
                          });

                          context.read<AuthenticationBloc>().add(
                                FetchSearchedUsers(
                                  value,
                                ),
                              );
                        });
                      },
                      searchHint: "Search people",
                      itemBuilder: (int index) {
                        final user =
                            authenticationState.searchableUsers?[index];
                        if (user == null) {
                          return const SizedBox();
                        }

                        final tiles = ListTile(
                          title: Text(user.name ?? ''),
                          onTap: () {
                            sl<RouteHelper>().popToPreviousPage(result: user);
                          },
                        );

                        return tiles;
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Padding _buildNoClubState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  'You are not in any clubs. ',
                  style: context.textTheme.headlineSmall!.copyWith(
                    color: DojoDexColors.gray2,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'You are not eligible to search for users yet.',
                  style: context.textTheme.titleMedium!.copyWith(
                    color: DojoDexColors.gray2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
