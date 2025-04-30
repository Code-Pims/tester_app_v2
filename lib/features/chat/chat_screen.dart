import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
import 'package:dojodex_instructor/blocs/sp_message/sp_message_bloc.dart';
import 'package:dojodex_instructor/features/chat/chat_bubble_widget.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:dojodex_common/models/user/user.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatArguments {
  final User? userToChat;
  final SPMessage? message;
  final String? key;

  const ChatArguments({
    required this.userToChat,
    this.message,
    this.key,
  });
}

class ChatScreen extends StatefulWidget {
  final User? user;
  final SPMessage? message;
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

  @override
  void initState() {
    context.read<SpMessageBloc>().add(const ListenToMessagesLocal());
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
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<SpMessageBloc, SPMessageState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                if (widget.user?.id == null) {
                  return const SizedBox();
                }
                final messages = state.getMessages(widget.mapKey ?? '');
                return BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, authenticationState) {
                    final isDirectMessage = widget.message is DirectMessage;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      reverse: isDirectMessage,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];

                        bool isSender = false;

                        if (message is DirectMessage) {
                          isSender = message.senderId ==
                              authenticationState.user?.id.toString();
                        }

                        if (message is ClubMessage) {
                          return ChatBubbleWidget(
                            text: message.content ?? "",
                            isSender: isSender,
                            senderName: message.clubName,
                          );
                        }
                        return ChatBubbleWidget(
                          text: message.content ?? "",
                          isSender: isSender,
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
      // ),
    );
  }

  Widget _maybeBuildSendMessage() {
    if (widget.message is AnnouncementMessage) {
      return const SizedBox();
    }

    return BlocConsumer<SpMessageBloc, SPMessageState>(
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
                      decoration: const InputDecoration(
                        hintText: "Message",
                      ),
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
                              SPMessage? message;

                              if (_messageController.text == '') {
                                return;
                              }

                              if (widget.message is DirectMessage) {
                                final directMessage =
                                    widget.message as DirectMessage;
                                message = directMessage.copyWith(
                                  content: _messageController.text,
                                );
                              }

                              if (widget.message is ClubMessage) {
                                final clubMessage =
                                    widget.message as ClubMessage;
                                message = clubMessage.copyWith(
                                  content: _messageController.text,
                                );
                              }
                              if (message == null) {
                                return;
                              }

                              context.read<SpMessageBloc>().add(
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
            Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom)),
          ],
        );
      },
    );
  }
}
