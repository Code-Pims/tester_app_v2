import 'package:dojodex_instructor/common/architecture/supabase_base_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/models/sp_message/sp_message.dart';
import 'package:dojodex_common/models/sp_message/sp_message_converter.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMessageRepository extends SupabaseBaseRepository {
  SupabaseMessageRepository({required SupabaseClient supabase})
      : super(supabase);

  Future<List<SPMessage>?> fetchMyMessages({
    required String userId,
  }) async {
    const announcementId = 0;
    try {
      final response = await supabase.from(messagesTable).select().or(
            'receiver_id.eq.$userId,sender_id.eq.$userId,announcement_id.eq.$announcementId',
          );

      final data = response as List<dynamic>;

      sl<Logger>().d('User: $userId');
      sl<Logger>().d('Messages: $data');

      return data
          .map((json) => const SPMessageConverter().fromJson(json))
          .toList();
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<List<SPMessage>?> fetchClubMessages({
    required List<String> clubIds,
  }) async {
    try {
      if (clubIds.isEmpty) {
        return [];
      }

      final response = await supabase
          .from(messagesTable)
          .select()
          .inFilter('club_id', clubIds);

      final data = response as List<dynamic>;

      return data
          .map((json) => const SPMessageConverter().fromJson(json))
          .toList();
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  RealtimeChannel? listenToReceiverMessages(
    void Function(PostgresChangePayload) onChange, {
    required String userId,
  }) {
    return supabase
        .channel('public:${messagesTable}Receiver')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: publicSchema,
          table: messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) {
            sl<Logger>().d('Message payload receiver: $payload');
            onChange(payload);
          },
        );
  }

  RealtimeChannel? listenToSenderMessages(
    void Function(PostgresChangePayload) onChange, {
    required String userId,
  }) {
    return supabase.channel('public:${messagesTable}Sender').onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: publicSchema,
          table: messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'sender_id',
            value: userId,
          ),
          callback: (payload) {
            sl<Logger>().d('Message payload sender: $payload');
            onChange(payload);
          },
        );
  }

  RealtimeChannel? listenToClubMessages(
    void Function(PostgresChangePayload) onChange, {
    List<String>? clubIds,
  }) {
    return supabase.channel('public:${messagesTable}Club').onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: publicSchema,
          table: messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.inFilter,
            column: 'club_id',
            value: clubIds,
          ),
          callback: (payload) {
            sl<Logger>().d('Message payload club: $payload');
            onChange(payload);
          },
        );
  }

  Future<void> insertMessage(SPMessage message) async {
    try {
      await supabase.from(messagesTable).insert(
            message.toJson()
              ..remove('id')
              ..remove('created_at'),
          );
    } on Exception catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }
}
