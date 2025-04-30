import 'package:dojodex_common/models/message/message.dart';
import 'package:dojodex_common/models/user/user.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/blocs/message/message_bloc.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/chat/chat_bubble_widget.dart';
import 'package:flutter/material.dart';
import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class ChatArguments {
  final User? userToChat;
  final Message? message;
  final String? key;
  const ChatArguments({
    required this.userToChat,
    this.message,
    this.key,
  });
}

class ChatScreen extends StatefulWidget {
  final User? user;
  final Message? message;
  final String? mapKey;
  ChatScreen({
    required ChatArguments arguments,
    super.key,
  })  : user = arguments.userToChat,
        message = arguments.message,
        mapKey = arguments.key;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late RefreshController _refreshController;
  late bool isRefreshing;

  @override
  void initState() {
    isRefreshing = false;

    _refreshController = RefreshController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              widget.user?.name ?? "",
              style: context.textTheme.headlineSmall,
            ),
          ],
        ),
        actions: [
          /// refresh button
          !isRefreshing
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _refreshController.requestRefresh();
                  },
                )
              : const SizedBox(),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        header: const WaterDropHeader(),
        enablePullDown: true,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<MessageBloc, MessageState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  if (widget.user?.id == null) {
                    return const SizedBox();
                  }

                  final messages = state.getMessages(widget.mapKey ?? '');
                  return BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, authenticationState) {
                      final isDirectMessage = widget.message is DirectMessage;

                      return BlocConsumer<MessageBloc, MessageState>(
                        listenWhen: (previous, current) =>
                            previous.isLoading != current.isLoading,
                        listener: (context, state) {
                          sl<Logger>().i(state.isLoading);
                          if ((state.isLoading ?? false)) {
                            _refreshController.requestRefresh();
                          }
                          if (!(state.isLoading ?? false)) {
                            setState(() {
                              isRefreshing = false;
                            });
                            _refreshController.refreshCompleted();
                          }
                        },
                        builder: (context, state) {
                          return ListView.builder(
                            reverse: isDirectMessage,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isSender =
                                  authenticationState.user?.id.toString() ==
                                      message.messageFrom?.userId.toString();
                              if (message is ClubMessage) {
                                return ChatBubbleWidget(
                                  text: message.message ?? "",
                                  isSender: isSender,
                                  senderName: message.messageFrom?.name,
                                );
                              }
                              return ChatBubbleWidget(
                                text: message.message ?? "",
                                isSender: isSender,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            _maybeBuildSendMessage(),
          ],
        ),
      ),
    );
  }

  void _onRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    context.read<ClubBloc>().add(const FetchClubs());
    context.read<MessageBloc>().add(const FetchAllMessages());
  }

  void _onLoading() async {
    setState(() {
      isRefreshing = false;
    });
    _refreshController.loadComplete();
  }

  Widget _maybeBuildSendMessage() {
    if (widget.message is AnnouncementMessage) {
      return const SizedBox();
    }
    return BlocConsumer<MessageBloc, MessageState>(
      listener: (context, state) {
        final isLoading =
            (state.isSendingMessage ?? false) && (state.isLoading ?? false);
        if (isLoading) {
          return;
        }
        _messageController.clear();
      },
      builder: (context, state) {
        final isLoading =
            (state.isSendingMessage ?? false) || (state.isLoading ?? false);
        return Column(
          children: [
            isLoading ? const LinearProgressIndicator() : const SizedBox(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: TextField(
                      style: context.textTheme.bodyMedium,
                      minLines: 1,
                      maxLines: null,
                      controller: _messageController,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Message? message;

                              if (_messageController.text == '') {
                                return;
                              }

                              if (widget.message is DirectMessage) {
                                final directMessage =
                                    widget.message as DirectMessage;
                                message = directMessage.copyWith(
                                  message: _messageController.text,
                                );
                              }

                              if (widget.message is ClubMessage) {
                                final clubMessage =
                                    widget.message as ClubMessage;
                                message = clubMessage.copyWith(
                                  message: _messageController.text,
                                );
                              }

                              context.read<MessageBloc>().add(
                                    SendMessage(
                                      message: message,
                                    ),
                                  );
                            },
                      icon: const Icon(
                        Icons.send,
                        color: DojoDexColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
