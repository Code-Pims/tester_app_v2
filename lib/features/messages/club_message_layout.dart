import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/chat/chat_screen.dart';
import 'package:dojodex_instructor/features/messages/message_tile.dart';
import 'package:dojodex_common/models/models.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:flutter/material.dart';

class ClubMessageLayout extends StatelessWidget {
  final ClubMessage message;
  final String messageKey;

  const ClubMessageLayout({
    super.key,
    required this.message,
    required this.messageKey,
  });

  @override
  Widget build(BuildContext context) {
    return MessageTile(
      title: message.clubName ?? '',
      avatarUrl: message.clubAvatarUrl,
      message: message,
      onTap: () {
        final arguments = ChatArguments(
          userToChat: User(
            id: int.parse(message.clubId!),
            name: message.clubName,
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
