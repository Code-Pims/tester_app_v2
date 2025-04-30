import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/chat/chat_screen.dart';
import 'package:dojodex_instructor/features/messages/message_tile.dart';
import 'package:dojodex_common/models/models.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:flutter/material.dart';

class AnnouncementMessageLayout extends StatelessWidget {
  final AnnouncementMessage message;
  final String messageKey;

  const AnnouncementMessageLayout({
    super.key,
    required this.message,
    required this.messageKey,
  });

  @override
  Widget build(BuildContext context) {
    return MessageTile(
      title: message.announcementDisplayName ?? 'DojoDex',
      avatarUrl: message.announcementAvatarUrl,
      message: message,
      onTap: () {
        final arguments = ChatArguments(
          userToChat: User(
            id: int.parse(message.announcementId ?? '0'),
            name: message.announcementDisplayName ?? 'DojoDex',
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
