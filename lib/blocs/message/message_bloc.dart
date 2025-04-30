import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dojodex_common/dojodex_architecture.dart';
import 'package:dojodex_common/models/message/message.dart';
import 'package:dojodex_common/models/message/message_from.dart';
import 'package:dojodex_instructor/common/services/user_service.dart';
import 'package:dojodex_instructor/data/repositories/message_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:logger/web.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository messageRepository;
  MessageBloc()
      : messageRepository = sl<MessageRepository>(),
        super(MessageState.initial()) {
    on<FetchAllMessages>(_onFetchAllMessages);
    on<SendMessage>(_onSendMessage);
  }

  /// close the subscription when the bloc is closed
  @override
  Future<void> close() {
    return super.close();
  }

  FutureOr<void> _onFetchAllMessages(
    FetchAllMessages event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final userService = sl<UserService>();

      final user = await userService.getUser();
      sl<Logger>().i(user);
      if (user == null) {
        emit(state.copyWith(
          isLoading: false,
        ));
        return;
      }
      final messages = await messageRepository.fetchAllMessages(
        userId: user.id.toString(),
      );

      emit(state.copyWith(
        isLoading: false,
        isSendingMessage: false,
        messages: messages,
      ));
    } catch (e) {
      sl<Logger>().e(e);
      emit(state.copyWith(
        isLoading: false,
        isSendingMessage: false,
      ));
    }
  }

  FutureOr<void> _onSendMessage(
    SendMessage event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(
      isSendingMessage: true,
    ));

    try {
      Message? message;
      final userService = sl<UserService>();

      final user = await userService.getUser();

      /// Given that
      /// it has a message
      /// it has a message_to
      /// type as default
      if (event.message is DirectMessage) {
        final directMessage = event.message as DirectMessage;
        message = directMessage.copyWith(
          messageStatus: 'unread',
          messageFrom: MessageUser(
            userId: user?.id,
            name: user?.name,
          ),
          messageSubject: '',
        );
      }

      if (event.message is ClubMessage) {
        final clubMessage = event.message as ClubMessage;
        message = clubMessage.copyWith(
          messageStatus: 'unread',
          messageFrom: MessageUser(
            userId: user?.id,
            name: user?.name,
          ),
          messageSubject: '',
        );
      }

      await messageRepository.sendMessage(message: message);

      add(const FetchAllMessages());
    } catch (e) {
      sl<Logger>().e(e);
      emit(state.copyWith(
        isSendingMessage: false,
      ));
    }
  }
}
