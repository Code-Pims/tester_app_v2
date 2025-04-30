import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String title;
  final SPMessage message;
  final String? avatarUrl;
  final Widget? avatar;
  final VoidCallback onTap;

  const MessageTile({
    required this.title,
    required this.message,
    required this.avatarUrl,
    this.avatar,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Row(
        children: [
          avatar ??
              ProfileImage(
                profileImage: avatarUrl,
                size: 25,
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Builder(builder: (context) {
                  if (message is AnnouncementMessage) {
                    return Text(
                      message.content ?? '',
                      style: context.textTheme.bodySmall,
                    );
                  }
                  return Text(
                    message.content ?? '',
                    style: context.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: DojoDexColors.gray4,
          ),
        ],
      ),
    );
  }
}
