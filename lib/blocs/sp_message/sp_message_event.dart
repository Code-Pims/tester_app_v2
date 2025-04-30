part of 'sp_message_bloc.dart';

abstract class SPMessageEvent extends BlocEvent {
  const SPMessageEvent();
}

class ListenToDirectMessages extends SPMessageEvent {
  const ListenToDirectMessages();

  @override
  List<Object> get props => [];
}

class ListenToClubMessages extends SPMessageEvent {
  final List<String> clubIds;

  const ListenToClubMessages({required this.clubIds});

  @override
  List<Object> get props => [clubIds];
}

class FetchDirectMessages extends SPMessageEvent {
  const FetchDirectMessages();

  @override
  List<Object> get props => [];
}

class FetchClubMessages extends SPMessageEvent {
  final List<String> clubIds;

  const FetchClubMessages({
    required this.clubIds,
  });

  @override
  List<Object> get props => [];
}

class SendMessage extends SPMessageEvent {
  final SPMessage? message;
  const SendMessage({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ListenToMessagesLocal extends SPMessageEvent {
  const ListenToMessagesLocal();

  @override
  List<Object> get props => [];
}

class StoreMessages extends SPMessageEvent {
  final List<SPMessage>? messages;
  const StoreMessages({
    this.messages,
  });

  @override
  List<Object?> get props => [messages];
}
