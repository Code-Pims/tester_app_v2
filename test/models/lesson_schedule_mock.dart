import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_schedule_mock.freezed.dart';
part 'lesson_schedule_mock.g.dart';

@freezed
class LessonScheduleMock with _$LessonScheduleMock {
  const factory LessonScheduleMock({
    int? schedID,
    int? clubID,
    String? day,
    String? locationName,
    DateTime? startTime,
    DateTime? endTime,
    int? minAge,
    int? maxAge,
    int? minGrade,
    int? maxGrade,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _LessonScheduleMock;

  factory LessonScheduleMock.fromJson(Map<String, dynamic> json) =>
      _$LessonScheduleMockFromJson(json);

  /// get if has has LessonScheduleMock
  /// id != null
  // bool get isUpdate => schedID != null;
  bool get isUpdate => false;

  const LessonScheduleMock._();
}
