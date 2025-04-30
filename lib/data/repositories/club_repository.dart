import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dojodex_common/configs/grade_config.dart';
import 'package:dojodex_common/exceptions/common_exceptions.dart';
import 'package:dojodex_common/exceptions/custom_exception_converter.dart';
import 'package:dojodex_common/models/art/art.dart';
import 'package:dojodex_common/models/card_type/card_type.dart';
import 'package:dojodex_common/models/config/config.dart';
import 'package:dojodex_common/models/grades/grade.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_common/models/student/student.dart';
import 'package:dojodex_instructor/common/architecture/base_repository.dart';
import 'package:dojodex_instructor/data/database/sqflite_helper/sqflite_clubs_list.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/env/env.dart';
import 'package:dojodex_common/models/club/club.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/web.dart';

import '../database/sqflite_helper/sqflite_students_list.dart';

class ClubRepository extends BaseRepository {
  ClubRepository({required Dio dio}) : super(dio);

  Future<List<Club>?> fetchClubs({int? userId}) async {
    String url =
        "/wcra/v1/instructor_myclubs/?secret_key=${EnvValues.secretKey}";

    url = "$url&userid=$userId";

    try {
      final response = await dio.get(url);

      final data = response.data['data'];

      log("check data   ==>   $data");

      final lists = (data as List)
          .map(
            (e) => Club.fromJson(e),
          )
          .toList();

      /// Store clubs list into local DB
      List<Map<String, dynamic>> clubs =
          lists.map((club) => club.toJson()).toList();
      await storeClubsListIntoLocalDB(clubs);

      return lists;
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<List<Student>?> fetchClubStudents(
    int clubId, {
    LessonSchedule? lessonSchedule,
  }) async {
    if (await InternetConnection().hasInternetAccess) {
      String url = "/wcra/v1/getstudentlink/?secret_key=${EnvValues.secretKey}";

      url = "$url&clubid=$clubId";

      if (lessonSchedule != null) {
        /// parse minGrade and maxGrade
        if (lessonSchedule.minGrade != null) {
          url = "$url&min_grade=${lessonSchedule.minGrade}";
        }
        if (lessonSchedule.maxGrade != null) {
          url = "$url&max_grade=${lessonSchedule.maxGrade}";
        }
        if (lessonSchedule.minAge != null) {
          url = "$url&min_age=${lessonSchedule.minAge}";
        }
        if (lessonSchedule.maxAge != null) {
          url = "$url&max_age=${lessonSchedule.maxAge}";
        }
      }

      try {
        final response = await dio.get(url);

        final data = response.data['data'];

        final lists = (data as List)
            .map(
              (e) => Student.fromJson(e),
            )
            .toList();

        /// Store student list into local DB
        List<Map<String, dynamic>> students =
            lists.map((student) => student.toJson()).toList();
        await storeStudentsListIntoLocalDB(students);

        return lists;
      } on DioException catch (e) {
        sl<Logger>().e(e);
        rethrow;
      }
    } else {
      return await fetchStudentsListFromLocalDB();
    }
  }

  Future<void> updateStudent(Student student) async {
    String url =
        "/wcra/v1/update_studentlink/?secret_key=${EnvValues.secretKey}";

    if (student.studentName != null) {
      url = "$url&name=${student.studentName}";
    }

    if (student.studentStatus != null) {
      url = "$url&status=${student.studentStatus}";
    }

    if (student.currentGrade != null) {
      url = "$url&current_grade=${student.currentGrade}";
    }

    url = "$url&studentlinkID=${student.id}";

    try {
      await dio.get(url);
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<void> storeStudentsListIntoLocalDB(
      List<Map<String, dynamic>> students) async {
    final dbHelper = SqfliteStudentsList();

    // Optional: Clear old data before inserting new
    await dbHelper.clearDatabase();

    for (var student in students) {
      await dbHelper.insertStudent({
        'id': student['id'],
        'user_id': student['user_id'],
        'student_name': student['student_name'],
        'student_status': student['student_status'],
        'current_grade': student['current_grade'],
        'dob': student['dob'],
      });
    }

    debugPrint("Students stored successfully into Local DB");
  }

  Future<List<Student>?> fetchStudentsListFromLocalDB() async {
    final dbHelper = SqfliteStudentsList();
    List<Map<String, dynamic>> studentsList = await dbHelper.getStudents();

    final lists = (studentsList as List)
        .map(
          (e) => Student.fromJson(e),
        )
        .toList();

    return lists;
  }

  Future<void> storeClubsListIntoLocalDB(
      List<Map<String, dynamic>> clubList) async {
    final dbHelper = SqfliteClubsList();

    // Optional: Clear old data before inserting new
    await dbHelper.clearDatabase();

    for (var club in clubList) {
      await dbHelper.insertClub({
        'id': club['id'],
        'instructor_id': club['instructor_id'],
        'title': club['title'],
        'description': club['description'],
        'cluburl': club['cluburl'],
        'email': club['email'],
        'website': club['website'],
        'primary_address': club['primary_address'],
        'timetable': club['timetable'] ?? "", // Handle empty timetable
        'imageurl': club['imageurl'],
      });
    }

    debugPrint("Clubs stored successfully into local DB");
  }

  Future<List<Grade>?> fetchGrades() async {
    try {
      /// Generate a fake response
      return GradesConfig.grades;
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<List<Art>?> fetchArts() async {
    try {
      /// Generate a fake response
      return const <Art>[
        Art(id: 1, name: "ITF Tae Kwon-Do"),
        Art(id: 2, name: "WT Tae Kwon-Do"),
        Art(id: 3, name: "TAGB Tae Kwon-Do"),
      ];
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<List<CardType>?> fetchCardTypes() async {
    try {
      /// Generate a fake response
      return const <CardType>[
        CardType(id: 1, name: "Move"),
        CardType(id: 2, name: "Body Part"),
        CardType(id: 3, name: "Number of moves"),
        CardType(id: 4, name: "Meaning"),
        CardType(id: 5, name: "History"),
        CardType(id: 6, name: "Command"),
        CardType(id: 7, name: "General"),
        CardType(id: 8, name: "Step Sparring"),
        CardType(id: 9, name: "Numbers"),
        CardType(id: 10, name: "Stances"),
      ];
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<Config> fetchConfig() async {
    String url = "/wcra/v1/clubs-configurations";

    try {
      final response = await dio.get(url);

      final locations = response.data['locations'] as List<dynamic>;
      final martialArtTypes = response.data['martial_art'] as List<dynamic>;

      final config = Config(
        locations: locations.map((e) => e.toString()).toList(),
        martialArtTypes: martialArtTypes.map((e) => e.toString()).toList(),
      );

      return config;
    } on DioException catch (e) {
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }

  Future<bool> addTheoryCard({
    String? clubId,
    String? martialArt,
    String? question,
    String? answer,
    String? minimumGrade,
    String? cardTypeFilter,
  }) async {
    String url = "/wcra/v1/addTheories/?secret_key=${EnvValues.secretKey}";

    Map<String, String> postParams = {
      "club_id": clubId ?? "",
      "title": question ?? "",
      "art": martialArt ?? "",
      "question": question ?? "",
      "answer": answer ?? "",
      "minGrade": minimumGrade ?? "",
      "card_type": cardTypeFilter ?? "",
    };

    try {
      final response = await dio.post(
        url,
        data: postParams,
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: response.data["data"]["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        return true;
      } else {
        Fluttertoast.showToast(
            msg: "Something went wrong!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
      }
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    } on NoCardsException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }
}
