part of 'message_bloc.dart';

class MessageState extends BlocState {
  final List<Message>? messages;
  final bool? isLoading;
  final bool? isSendingMessage;
  final Exception? error;

  const MessageState({
    this.messages,
    this.isLoading,
    this.error,
    this.isSendingMessage,
  });

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        error,
        isSendingMessage,
      ];

  MessageState copyWith({
    List<Message>? messages,
    bool? isLoading,
    Exception? error,
    bool? isSendingMessage,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
    );
  }

  factory MessageState.initial() {
    return const MessageState(
      messages: [],
      isLoading: false,
      error: null,
      isSendingMessage: false,
    );
  }

  /// The key should be a string
  /// So the output will be like this:
  /// { '1': [Message, Message, Message], '2': [Message, Message] }
  /// If the [messageTo] is empty, it's either [announcement] or [group]
  /// If [messageType] is [direct], group it by [messageFrom.userId]
  /// Check the [messageTo], if [messageTo] exists in the list, add the message to the list
  /// It means that I am sending a message to a user
  /// If [messageType] is [announcement], do not group but it should be in the list with the key [messageId]
  /// If [messageType] is [group], the key should be [messageFromClub]

  Map<String, List<Message>> groupMessages(List<String> keys) {
    final Map<String, List<Message>> groupedMessages = {};
    for (final message in messages!) {
      if (message is DirectMessage) {
        final key = getConversationKey(
          message.messageFrom?.userId,
          message.messageTo?.userId,
        );

        if (groupedMessages.containsKey(key)) {
          groupedMessages[key]!.add(message);
        } else {
          groupedMessages[key!] = [message];
        }
      } else if (message is AnnouncementMessage) {
        final key = message.messageId.toString();
        if (groupedMessages.containsKey(key)) {
          groupedMessages[key]!.add(message);
        } else {
          groupedMessages[key] = [message];
        }
      } else if (message is ClubMessage) {
        final key = message.messageFromClub.toString();
        if (groupedMessages.containsKey(key)) {
          groupedMessages[key]!.add(message);
        } else {
          groupedMessages[key] = [message];
        }
      }
    }

    /// Add non-existing club messages from the parameters List<String> [keys]
    /// If the key is not in the groupedMessages, add it with an empty list
    for (final key in keys) {
      if (!groupedMessages.containsKey(key)) {
        groupedMessages[key] = [];
      }
    }
    sl<Logger>().i(groupedMessages);

// Sort the groupedMessages by the highest messageId in each group
    final sortedGroupedMessages = Map<String, List<Message>>.fromEntries(
      groupedMessages.entries.toList()
        ..sort((a, b) {
          final highestMessageIdA = a.value.isNotEmpty
              ? a.value
                  .map((m) => int.parse(m.messageId!))
                  .reduce((a, b) => a > b ? a : b)
              : 0;
          final highestMessageIdB = b.value.isNotEmpty
              ? b.value
                  .map((m) => int.parse(m.messageId!))
                  .reduce((a, b) => a > b ? a : b)
              : 0;
          return highestMessageIdB.compareTo(highestMessageIdA);
        }),
    );

    return sortedGroupedMessages;
  }

  String? getConversationKey(int? userId1, int? userId2) {
    if (userId1 == null) {
      return '';
    }
    final ids = [userId1, userId2].where((id) => id != null).toList();
    ids.sort();
    return ids.join('_');
  }

  /// from the group messages, get the latest message
  /// I will pass String, List<Message> to the function
  /// The latest message would be the highest number of [messageId]

  Message? getLatestMessage(String key, List<Message> messages) {
    final List<Message> sortedMessages = messages;
    if (sortedMessages.isNotEmpty) {
      sortedMessages.sort((a, b) => b.messageId!.compareTo(a.messageId!));
      return sortedMessages.first;
    } else {
      // Handle the case where the messages list is empty
      return null; // or any other appropriate default value
    }
  }

  /// I use [getConversationKey] to get the key
  /// and sort by messageId

  List<Message> getMessages(String key) {
    final List<Message> messages = this.messages!.where((message) {
      if (message is DirectMessage) {
        return getConversationKey(
                message.messageFrom?.userId, message.messageTo?.userId) ==
            key;
      } else if (message is AnnouncementMessage) {
        return message.messageId.toString() == key;
      } else if (message is ClubMessage) {
        return message.messageFromClub.toString() == key;
      }
      return false;
    }).toList();

    /// Remove the duplicates
    final Set<int> newMessages = {};
    messages.removeWhere((element) {
      if (newMessages.contains(int.parse(element.messageId.toString()))) {
        return true;
      }
      newMessages.add(int.parse(element.messageId.toString()));
      return false;
    });

    messages.sort((a, b) => b.messageId!.compareTo(a.messageId!));

    return messages;
  }

  /// Search the conversation by the key
  /// If the key is the same as the current user, return the other user
  /// Get the other info of the other user from the messageFrom
  /// To return messageFrom
  ///

  MessageUser? getConversation(String key) {
    final List<Message> messages = getMessages(key);
    final Message latestMessage = getLatestMessage(key, messages)!;
    if (latestMessage is DirectMessage) {
      if (latestMessage.messageFrom?.userId.toString() == key) {
        return latestMessage.messageTo;
      }
      return latestMessage.messageFrom;
    } else if (latestMessage is AnnouncementMessage) {
      return latestMessage.messageFrom;
    } else if (latestMessage is ClubMessage) {
      return latestMessage.messageFrom;
    }

    return null;
  }

  /// I will pass a userId parameter
  /// Get the other user from the conversation
  /// If the userId is the same as the messageFrom, return the messageTo

  MessageUser? getOtherUser(String key, int userId) {
    final List<Message> messages = getMessages(key);
    final Message latestMessage = getLatestMessage(key, messages)!;
    if (latestMessage is DirectMessage) {
      if (latestMessage.messageFrom?.userId == userId) {
        return latestMessage.messageTo;
      }
      return latestMessage.messageFrom;
    } else if (latestMessage is AnnouncementMessage) {
      return latestMessage.messageFrom;
    } else if (latestMessage is ClubMessage) {
      return latestMessage.messageFrom;
    }

    return null;
  }
}
