import 'package:dojodex_common/dojdex_models.dart';
import 'package:dojodex_instructor/blocs/sp_message/sp_message_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/common/services/user_service.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/features/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchUserWidget extends StatelessWidget {
  const SearchUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        /// Show user search screen
        /// [receiver] is the user to chat with
        final result = await sl<RouteHelper>().showUserSearchScreen();
        if (result == null) {
          return;
        }

        /// user to chat with
        if (result is User) {
          final user = result;
          final currentUser = await sl<UserService>().getUser();
           if (!context.mounted) return;
          final mapKey = context.read<SpMessageBloc>().state.getConversationKey(
              user.id.toString(), currentUser?.id.toString());
          sl<RouteHelper>().showChatScreen(
            ChatArguments(
              userToChat: user,
              message: DirectMessage(
                senderId: currentUser?.id.toString(),
                receiverId: user.id.toString(),
                receiverDisplayName: user.name,
                receiverAvatarUrl: user.getLatestAvatarUrl,
                createdAt: DateTime.now(),
              ),
              key: mapKey,
            ),
          );
        }

        /// club to chat with
        if (result is Club) {
          final club = result;
          final currentUser = await sl<UserService>().getUser();
          final mapKey = club.id.toString();

          final arguments = ChatArguments(
            userToChat: User(
              id: club.id,
              name: club.title,
            ),
            message: ClubMessage(
              senderId: currentUser?.id.toString(),
              senderDisplayName: currentUser?.name,
              senderAvatarUrl: currentUser?.getLatestAvatarUrl,
              clubId: club.id.toString(),
              clubName: club.title,
              clubAvatarUrl: club.imageurl,
              createdAt: DateTime.now(),
            ),
            key: mapKey,
          );
          sl<RouteHelper>().showChatScreen(
            arguments,
          );
        }
      },
      child: const IgnorePointer(
        ignoring: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CustomSearchView(
            hintText: 'Search people',
          ),
        ),
      ),
    );
  }
}
