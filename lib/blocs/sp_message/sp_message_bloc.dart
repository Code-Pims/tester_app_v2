import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dojodex_common/dojodex_architecture.dart';
import 'package:dojodex_instructor/common/services/user_service.dart';
import 'package:dojodex_instructor/data/database/database_service.dart';
import 'package:dojodex_instructor/data/database/databases.dart';
import 'package:dojodex_instructor/data/repositories/sp_message_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:dojodex_common/models/sp_message/sp_message_converter.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sp_message_event.dart';
part 'sp_message_state.dart';

class SpMessageBloc extends Bloc<SPMessageEvent, SPMessageState> {
  final SupabaseMessageRepository messageRepository;

  RealtimeChannel? messageReceiverRealTimeChannel;
  RealtimeChannel? messageSenderRealTimeChannel;
  RealtimeChannel? messageClubRealTimeChannel;

  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;

  SpMessageBloc()
      : messageRepository = sl<SupabaseMessageRepository>(),
        super(SPMessageState.initial()) {
    on<FetchDirectMessages>(_onFetchDirectMessages);
    on<FetchClubMessages>(_onFetchClubMessages);
    on<ListenToDirectMessages>(_onListenToDirectMessages);
    on<ListenToClubMessages>(_onListenToClubMessages);
    on<SendMessage>(_onSendMessage);
    on<ListenToMessagesLocal>(_onListenToMessagesLocal);
    on<StoreMessages>(_onStoreMessages);
  }

  FutureOr<void> _onListenToDirectMessages(
      ListenToDirectMessages event, Emitter<SPMessageState> emit) async {
    final user = await sl<UserService>().getUser();

    if (user == null) {
      return;
    }
    // Ensure previous subscriptions are canceled before creating new ones
    messageReceiverRealTimeChannel?.unsubscribe();
    messageSenderRealTimeChannel?.unsubscribe();

    messageReceiverRealTimeChannel = messageRepository
        .listenToReceiverMessages(
      _handleMessageChanges,
      userId: user.id.toString(),
    )
        ?.subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        sl<Logger>().d('Subscribed to receiver messages');
      } else if (status == RealtimeSubscribeStatus.closed) {
        sl<Logger>().d('Unsubscribed from receiver messages updates');
      }
    });

    messageSenderRealTimeChannel = messageRepository
        .listenToSenderMessages(
      _handleMessageChanges,
      userId: user.id.toString(),
    )
        ?.subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        sl<Logger>().d('Subscribed to sender messages');
      } else if (status == RealtimeSubscribeStatus.closed) {
        sl<Logger>().d('Unsubscribed from messages updates');
      }
    });
  }

  void _handleMessageChanges(PostgresChangePayload payload) async {
    final databaseService = sl<DatabaseService>();

    await databaseService.eventFromPostgressPayload(payload);
    add(const ListenToMessagesLocal());
  }

  FutureOr<void> _onSendMessage(
    SendMessage event,
    Emitter<SPMessageState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    SPMessage? message;
    final userService = sl<UserService>();

    final user = await userService.getUser();

    if (user == null) {
      return;
    }

    if (event.message is DirectMessage) {
      final directMessage = event.message as DirectMessage;

      final receiverUserDisplayName =
          state.getReceiverUserDisplayName(user.id.toString(), directMessage);
      final receiverUserId =
          state.getReceiverUserId(user.id.toString(), directMessage);
      final receiverUserAvatarUrl =
          state.getReceiverUserAvatar(user.id.toString(), directMessage);

      message = directMessage.copyWith(
        /// sender
        senderId: user.id.toString(),
        senderDisplayName: user.name,
        senderAvatarUrl: user.getLatestAvatarUrl,

        /// receiver
        receiverId: receiverUserId,
        receiverDisplayName: receiverUserDisplayName,
        receiverAvatarUrl: receiverUserAvatarUrl,

        /// seenBy default the sender
        /// Map<String, DateTime> seenBy,
        seenBy: {
          user.id.toString(): DateTime.now(),
        },
      );
    }

    if (event.message is ClubMessage) {
      final clubMessage = event.message as ClubMessage;

      message = clubMessage.copyWith(
        /// sender
        senderId: user.id.toString(),
        senderDisplayName: user.name,
        senderAvatarUrl: user.getLatestAvatarUrl,
        createdAt: DateTime.now(),
      );
    }

    if (message == null) {
      return;
    }

    try {
      await messageRepository.insertMessage(message);
      emit(state.copyWith(isLoading: false));
    } on Exception catch (e) {
      sl<Logger>().e(e);
      emit(state.copyWith(isLoading: false));
    }
  }

  FutureOr<void> _onListenToMessagesLocal(
    ListenToMessagesLocal event,
    Emitter<SPMessageState> emit,
  ) {
    _messageSubscription?.cancel();

    final databaseService = sl<DatabaseService>();
    _messageSubscription = databaseService
        .multipleListen(
      MessagesTable().name,
    )
        .listen(
      (data) {
        final List<SPMessage> items = [];
        for (var element in data) {
          items.add(const SPMessageConverter().fromJson(element));
        }

        add(StoreMessages(messages: items));
      },
    );
  }

  FutureOr<void> _onStoreMessages(
    StoreMessages event,
    Emitter<SPMessageState> emit,
  ) {
    emit(state.copyWith(
      messages: event.messages,
    ));
  }

  FutureOr<void> _onFetchDirectMessages(
      FetchDirectMessages event, Emitter<SPMessageState> emit) async {
    emit(state.copyWith(isLoading: true));

    final user = await sl<UserService>().getUser();

    if (user == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    try {
      final messages = await messageRepository.fetchMyMessages(
        userId: user.id.toString(),
      );

      final databaseService = sl<DatabaseService>();

      if (messages?.isNotEmpty ?? false) {
        for (var i = 0; i < (messages?.length ?? 0); i++) {
          final message = messages![i];
          await databaseService.insertOrUpdate(
            MessagesTable().name,
            message.id.toString(),
            message.toJson(),
          );
        }
      }

      emit(state.copyWith(
        isLoading: false,
      ));
    } on Exception catch (e) {
      sl<Logger>().e(e);
      emit(state.copyWith(isLoading: false));
    }
  }

  FutureOr<void> _onFetchClubMessages(
    FetchClubMessages event,
    Emitter<SPMessageState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final messages = await messageRepository.fetchClubMessages(
        clubIds: event.clubIds,
      );

      final databaseService = sl<DatabaseService>();

      if (messages?.isNotEmpty ?? false) {
        for (var i = 0; i < (messages?.length ?? 0); i++) {
          final message = messages![i];
          await databaseService.insertOrUpdate(
            MessagesTable().name,
            message.id.toString(),
            message.toJson(),
          );
        }
      }

      emit(state.copyWith(
        isLoading: false,
      ));
    } on Exception catch (e) {
      sl<Logger>().e(e);
      emit(state.copyWith(isLoading: false));
    }
  }

  FutureOr<void> _onListenToClubMessages(
      ListenToClubMessages event, Emitter<SPMessageState> emit) {
    messageClubRealTimeChannel?.unsubscribe();

    messageClubRealTimeChannel = messageRepository
        .listenToClubMessages(
      _handleMessageChanges,
      clubIds: event.clubIds,
    )
        ?.subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        sl<Logger>().d('Subscribed to Club messages');
      } else if (status == RealtimeSubscribeStatus.closed) {
        sl<Logger>().d('Unsubscribed from Club messages updates');
      }
    });
  }
}
