part of 'sp_message_bloc.dart';

class SPMessageState extends BlocState {
  final List<SPMessage>? messages;
  final bool? isLoading;
  final bool? isSendingMessage;
  final Exception? error;

  const SPMessageState({
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

  SPMessageState copyWith({
    List<SPMessage>? messages,
    bool? isLoading,
    Exception? error,
    bool? isSendingMessage,
  }) {
    return SPMessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
    );
  }

  factory SPMessageState.initial() {
    return const SPMessageState(
      messages: [],
      isLoading: false,
      error: null,
      isSendingMessage: false,
    );
  }

  Map<String, List<SPMessage>> groupMessages() {
    final Map<String, List<SPMessage>> groupedMessages = {};
    for (final message in messages!) {
      if (message is DirectMessage) {
        final key = getConversationKey(
          message.senderId!,
          message.receiverId!,
        );

        if (groupedMessages.containsKey(key)) {
          groupedMessages[key]!.add(message);
        } else {
          groupedMessages[key!] = [message];
        }
      } else if (message is AnnouncementMessage) {
        final key = message.announcementId.toString();
        if (groupedMessages.containsKey(key)) {
          groupedMessages[key]!.add(message);
        } else {
          groupedMessages[key] = [message];
        }
      } else if (message is ClubMessage) {
        final key = message.clubId.toString();
        if (groupedMessages.containsKey(key)) {
          groupedMessages[key]!.add(message);
        } else {
          groupedMessages[key] = [message];
        }
      }
    }

    /// Sort the groupedMessages by the highest messageId in each group
    final sortedGroupedMessages = Map<String, List<SPMessage>>.fromEntries(
      groupedMessages.entries.toList()
        ..sort((a, b) {
          // Check if either group contains AnnouncementMessage
          final aContainsAnnouncement =
              a.value.any((m) => m is AnnouncementMessage);
          final bContainsAnnouncement =
              b.value.any((m) => m is AnnouncementMessage);

          if (aContainsAnnouncement && !bContainsAnnouncement) {
            return -1; // a should come before b
          } else if (!aContainsAnnouncement && bContainsAnnouncement) {
            return 1; // b should come before a
          }

          // If neither or both contain AnnouncementMessage, sort by highest messageId
          final highestMessageIdA =
              a.value.map((m) => m.id!).reduce((a, b) => a > b ? a : b);
          final highestMessageIdB =
              b.value.map((m) => m.id!).reduce((a, b) => a > b ? a : b);
          return highestMessageIdB.compareTo(highestMessageIdA);
        }),
    );

    return sortedGroupedMessages;
  }

  String? getConversationKey(String? userId1, String? userId2) {
    if (userId1 == null) {
      return '';
    }
    final ids = [userId1, userId2].where((id) => id != null).toList();
    ids.sort();
    return ids.join('_');
  }

  /// from the group messages, get the latest message
  /// I will pass String, List<Message> to the function
  /// The latest message would be the [createdAt]

  SPMessage? getLatestMessage(List<SPMessage> messages) {
    final List<SPMessage> sortedMessages = messages;
    sortedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedMessages.first;
  }

  /// I use [getConversationKey] to get the key
  /// and sort by messageId

  List<SPMessage> getMessages(String key) {
    final List<SPMessage> messages = this.messages?.where((message) {
          if (message is DirectMessage) {
            return getConversationKey(message.receiverId, message.senderId) ==
                key;
          } else if (message is AnnouncementMessage) {
            return message.announcementId.toString() == key;
          } else if (message is ClubMessage) {
            return message.clubId.toString() == key;
          }
          return false;
        }).toList() ??
        [];

    /// Remove the duplicates
    Set<SPMessage> newMessages = messages.map((e) => e).toSet();

    /// Convert the set to a list and sort by createdAt
    List<SPMessage> sortedMessages = newMessages.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedMessages;
  }

  /// return the other user
  /// I will pass the id of the current user
  /// if it matches the [senderId], return the [receiverId]
  /// else, return the [senderId]
  String? getReceiverUserId(String currentUserId, SPMessage message) {
    if (message is DirectMessage) {
      if (message.senderId == currentUserId) {
        return message.receiverId;
      }
      return message.senderId;
    }
    return null;
  }

  String? getReceiverUserDisplayName(String currentUserId, SPMessage message) {
    if (message is DirectMessage) {
      if (message.senderId == currentUserId) {
        return message.receiverDisplayName;
      }
      return message.senderDisplayName;
    }
    return null;
  }

  String? getReceiverUserAvatar(String currentUserId, SPMessage message) {
    if (message is DirectMessage) {
      if (message.senderId == currentUserId) {
        return message.receiverAvatarUrl;
      }
      return message.senderAvatarUrl;
    }
    return '';
  }

  /// Sorted by createdAt
  /// sort the [messages] by [createdAt]
  List<SPMessage> getSortedMessages() {
    final List<SPMessage> sortedMessages = messages!;
    sortedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedMessages;
  }
}
