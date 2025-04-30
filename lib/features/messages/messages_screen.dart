import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/blocs/sp_message/sp_message_bloc.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/messages/announcement_message_layout.dart';
import 'package:dojodex_instructor/features/messages/club_message_layout.dart';
import 'package:dojodex_instructor/features/messages/direct_message_layout.dart';
import 'package:dojodex_instructor/features/messages/search_user_widget.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:logger/web.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    context.read<ClubBloc>().add(const FetchClubs());
    context.read<SpMessageBloc>().add(const ListenToMessagesLocal());
    context.read<SpMessageBloc>().add(const ListenToDirectMessages());
    context.read<SpMessageBloc>().add(const FetchDirectMessages());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ColoredBox(
        color: DojoDexColors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              const SearchUserWidget(),
              Expanded(
                child: BlocConsumer<ClubBloc, ClubState>(
                  listenWhen: (previous, current) =>
                      previous.clubs != current.clubs,
                  listener: _handleClubMessages,
                  builder: (context, clubState) {
                    return BlocBuilder<SpMessageBloc, SPMessageState>(
                      builder: (context, spMessageState) {
                        final messages = spMessageState.groupMessages();

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages.values.elementAt(index);
                            final messageKey = messages.keys.elementAt(index);
                            final latestMessage =
                                spMessageState.getLatestMessage(
                              message,
                            );

                            if (latestMessage is DirectMessage) {
                              return BlocBuilder<AuthenticationBloc,
                                  AuthenticationState>(
                                builder: (context, authenticationState) {
                                  return DirectMessageLayout(
                                    message: latestMessage,
                                    state: spMessageState,
                                    currentUser: authenticationState.user!,
                                    messageKey: messageKey,
                                  );
                                },
                              );
                            }
                            if (latestMessage is ClubMessage) {
                              return ClubMessageLayout(
                                message: latestMessage,
                                messageKey: messageKey,
                              );
                            }
                            if (latestMessage is AnnouncementMessage) {
                              return AnnouncementMessageLayout(
                                message: latestMessage,
                                messageKey: messageKey,
                              );
                            }
                            return const SizedBox();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleClubMessages(BuildContext context, ClubState state) {
    if (state.clubs?.isEmpty ?? true) {
      sl<Logger>().i('No clubs found');
    }

    /// Fetch club messages
    final clubIds = state.clubs?.map((e) => e.id.toString());

    if (clubIds?.isNotEmpty ?? false) {
      context.read<SpMessageBloc>().add(
            ListenToClubMessages(
              clubIds: clubIds?.toList() ?? [],
            ),
          );
      context.read<SpMessageBloc>().add(
            FetchClubMessages(
              clubIds: clubIds?.toList() ?? [],
            ),
          );
    }
  }
}
