import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:dojodex_common/extensions/text_extension.dart';

class ChatBubbleWidget extends StatelessWidget {
  final bool isSender;
  final String text;
  final String? time;
  final String? senderName;

  const ChatBubbleWidget({
    super.key,
    required this.isSender,
    required this.text,
    this.time,
    this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width *
                    0.75, // 75% of screen width
              ),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isSender
                      ? DojoDexColors.primary.withValues(alpha: 0.6)
                      : DojoDexColors.gray5,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(builder: (context) {
                      return senderName != null
                          ? Column(
                              children: [
                                Text(
                                  senderName ?? "",
                                  style: context.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4.0),
                              ],
                            )
                          : const SizedBox();
                    }),
                    Text(
                      text,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
