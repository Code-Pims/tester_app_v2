import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

class DateTimeConverterMock implements JsonConverter<DateTime, dynamic> {
  const DateTimeConverterMock();

  @override
  DateTime fromJson(dynamic json) {
    if (json['startTime'] != null) {
      return DateFormat("HH:mm").parse(json['startTime']);
    }
    if (json['endTime'] != null) {
      return DateFormat("HH:mm").parse(json['endTime']);
    }

    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime? data) =>
      data == null ? null : DateFormat("HH:mm").format(data);
}
