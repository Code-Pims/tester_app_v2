import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dojodex_common/exceptions/custom_exception_converter.dart';
import 'package:dojodex_common/models/message/message.dart';
import 'package:dojodex_common/models/message/message_converter.dart';
import 'package:dojodex_instructor/common/architecture/base_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/env/env.dart';
import 'package:logger/web.dart';

class MessageRepository extends BaseRepository {
  MessageRepository({required Dio dio}) : super(dio);

  Future<List<Message>?> fetchAllMessages({
    String? userId,
  }) async {
    String url = "/wcra/v1/message_get/?secret_key=${EnvValues.secretKey}";
    String url1 = "/wcra/v1/message_from/?secret_key=${EnvValues.secretKey}";

    final Map<String, dynamic> dataParams = {
      "user_id": userId,
    };

    try {
      final response = await dio.post(
        url,
        data: dataParams,
      );
      final response1 = await dio.post(
        url1,
        data: dataParams,
      );

      final data = response.data['data'];
      final data1 = response1.data['data'];

      final lists = (data as List).map((e) {
        /// decode the e['message_from']
        e['message_from'] = jsonDecode(e['message_from']);
        if (e['message_to'] != null) {
          e['message_to'] = jsonDecode(e['message_to']);
        }
        return const MessageConverter().fromJson(e);
      }).toList();

      final lists1 = (data1 as List).map((e) {
        /// decode the e['message_from']
        e['message_from'] = jsonDecode(e['message_from']);
        if (e['message_to'] != null) {
          e['message_to'] = jsonDecode(e['message_to']);
        }
        return const MessageConverter().fromJson(e);
      }).toList();

      return lists + lists1;
    } on DioException catch (e) {
      sl<Logger>().e({"Error": e.error});
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }

  Future<void> sendMessage({
    Message? message,
  }) async {
    String url = "/wcra/v1/message_send/?secret_key=${EnvValues.secretKey}";

    if (message == null) {
      return;
    }

    Map<String, dynamic> dataParams = {};

    if (message is DirectMessage) {
      dataParams = {
        'type': message.messageType,
        'from': jsonEncode(message.messageFrom?.toJson() ?? ""),
        'subject': "Message from ${message.messageFrom?.name}",
        'status': message.messageStatus,
        'message': message.message,
        'to': message.messageTo != null
            ? jsonEncode(message.messageTo?.toJson() ?? "")
            : null,
      };
    }

    if (message is ClubMessage) {
      dataParams = {
        'type': message.messageType,
        'from': jsonEncode(message.messageFrom?.toJson() ?? ""),
        'from_club': message.messageFromClub,
        'subject': "Message from ${message.messageFrom?.name}",
        'status': message.messageStatus,
        'message': message.message,
      };
    }

    sl<Logger>().i(dataParams);

    try {
      await dio.post(
        url,
        data: dataParams,
      );
    } on DioException catch (e) {
      sl<Logger>().e({"Error": e.error});
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }
}
