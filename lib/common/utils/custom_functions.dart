import 'package:dojodex_common/models/grades/grade.dart';

/// Grade class
Grade findGradeByName<T>(List<Grade> grades, String name) {
  return grades.firstWhere((grade) => grade.name == name,
      orElse: () => throw Exception('Grade not found'));
}

Grade? findGradeByValue<T>(List<Grade> grades, String number) {
  if(grades.isNotEmpty) {
    return grades.firstWhere((grade) => grade.number == int.parse(number),
        orElse: () => throw Exception('Grade not found'));
  }
  else {
    return null;
  }
}

/// Date Time to String
/// Format: HH:mm
/// Example: 12:30
String timeToString(DateTime time) {
  return '${time.hour}:${time.minute}';
}

String concatCardTypes(List<String>? cardTypes) {
  if (cardTypes == null) {
    return "";
  }
  return cardTypes.join("_");
}
