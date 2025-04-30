part of 'message_bloc.dart';

abstract class MessageEvent extends BlocEvent {
  const MessageEvent();
}

class FetchAllMessages extends MessageEvent {
  const FetchAllMessages();

  @override
  List<Object> get props => [];
}

class SendMessage extends MessageEvent {
  final Message? message;
  const SendMessage({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class DeleteMessage extends MessageEvent {
  final String? messageId;
  const DeleteMessage({
    this.messageId,
  });

  @override
  List<Object?> get props => [messageId];
}
