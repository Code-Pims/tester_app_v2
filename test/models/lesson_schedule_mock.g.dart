// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_schedule_mock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonScheduleMockImpl _$$LessonScheduleMockImplFromJson(
        Map<String, dynamic> json) =>
    _$LessonScheduleMockImpl(
      schedID: (json['schedID'] as num?)?.toInt(),
      clubID: (json['clubID'] as num?)?.toInt(),
      day: json['day'] as String?,
      locationName: json['locationName'] as String?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      minAge: (json['minAge'] as num?)?.toInt(),
      maxAge: (json['maxAge'] as num?)?.toInt(),
      minGrade: (json['minGrade'] as num?)?.toInt(),
      maxGrade: (json['maxGrade'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$LessonScheduleMockImplToJson(
        _$LessonScheduleMockImpl instance) =>
    <String, dynamic>{
      'schedID': instance.schedID,
      'clubID': instance.clubID,
      'day': instance.day,
      'locationName': instance.locationName,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'minAge': instance.minAge,
      'maxAge': instance.maxAge,
      'minGrade': instance.minGrade,
      'maxGrade': instance.maxGrade,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
