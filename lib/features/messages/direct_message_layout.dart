import 'package:dojodex_instructor/blocs/sp_message/sp_message_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/chat/chat_screen.dart';
import 'package:dojodex_instructor/features/messages/message_tile.dart';
import 'package:dojodex_common/models/models.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:flutter/material.dart';

class DirectMessageLayout extends StatelessWidget {
  final DirectMessage message;
  final String messageKey;
  final User currentUser;
  final SPMessageState state;

  const DirectMessageLayout({
    super.key,
    required this.message,
    required this.messageKey,
    required this.currentUser,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final receiverDisplayName = state.getReceiverUserDisplayName(
      currentUser.id.toString(),
      message,
    );
    final receiverUserId = state.getReceiverUserId(
      currentUser.id.toString(),
      message,
    );
    final receiverUserAvatarUrl = state.getReceiverUserAvatar(
      currentUser.id.toString(),
      message,
    );

    return MessageTile(
      title: receiverDisplayName ?? '',
      avatarUrl: receiverUserAvatarUrl,
      message: message,
      onTap: () {
        final arguments = ChatArguments(
          userToChat: User(
            id: int.parse(receiverUserId!),
            name: receiverDisplayName,
          ),
          message: message,
          key: messageKey,
        );
        sl<RouteHelper>().showChatScreen(
          arguments,
        );
      },
    );
  }
}
