import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'lesson_schedule_mock.dart';

void main() {
  setUp(() async {});

  group("Lesson Schedule Parsing", () {
    test('It should successfully cast all data types', () async {
      /// GIVEN empty state

      /// WHEN we fetch the flash cards
      Map<String, dynamic> data = {
        "schedID": "6",
        "clubID": "7691",
        "day": "Monday",
        "locationName": "Matina, Davao City",
        "startTime": "16:00:00",
        "endTime": "19:00:00",
        "minAge": "15",
        "maxAge": "25",
        "minGrade": "9",
        "maxGrade": "3",
        "created_at": "2025-01-24 08:33:55",
        "updated_at": "2025-01-24 08:33:55"
      };

      data['schedID'] = data['schedID'] is String
          ? num.parse(data['schedID'])
          : data['schedID'];
      data['clubID'] =
          data['clubID'] is String ? num.parse(data['clubID']) : data['clubID'];

      data['minAge'] =
          data['minAge'] is String ? num.parse(data['minAge']) : data['minAge'];
      data['maxAge'] =
          data['maxAge'] is String ? num.parse(data['maxAge']) : data['maxAge'];
      data['minGrade'] = data['minGrade'] is String
          ? num.parse(data['minGrade'])
          : data['minGrade'];
      data['maxGrade'] = data['maxGrade'] is String
          ? num.parse(data['maxGrade'])
          : data['maxGrade'];

      data['startTime'] =
          DateFormat("HH:mm").parse(data['startTime']).toString();
      data['endTime'] = DateFormat("HH:mm").parse(data['endTime']).toString();

      LessonScheduleMock.fromJson(data);

      /// THEN cards should not be null
      // expect(data, isNotNull);
      // e['clubID'] =
      //     e['clubID'] is String ? int.parse(e['clubID']) : e['clubID'];

      // e['minAge'] =
      //     e['minAge'] is String ? int.parse(e['minAge']) : e['minAge'];
      // e['maxAge'] =
      //     e['maxAge'] is String ? int.parse(e['maxAge']) : e['maxAge'];
      // e['minGrade'] =
      //     e['minGrade'] is String ? int.parse(e['minGrade']) : e['minGrade'];
      // e['maxGrade'] =
      //     e['maxGrade'] is String ? int.parse(e['maxGrade']) : e['maxGrade'];
    });
  });
}
