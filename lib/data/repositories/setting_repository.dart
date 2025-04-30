import 'package:dio/dio.dart';
import 'package:dojodex_common/models/location/location.dart';
import 'package:dojodex_common/models/student/student.dart';
import 'package:dojodex_instructor/common/architecture/base_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/models/art/art.dart';
import 'package:dojodex_common/models/card_type/card_type.dart';
import 'package:dojodex_common/models/grades/grade.dart';
import 'package:logger/logger.dart';

import '../../env/env.dart';

class SettingRepository extends BaseRepository {
  SettingRepository({required Dio dio}) : super(dio);

  Future<List<Grade>?> fetchGrades() async {
    try {
      /// Generate a fake response
      return const <Grade>[
        Grade(id: 1, name: "10th Kup", number: -10),
        Grade(id: 1, name: "9th Kup", number: -9),
        Grade(id: 2, name: "8th Kup", number: -8),
        Grade(id: 3, name: "7th Kup", number: -7),
        Grade(id: 4, name: "6th Kup", number: -6),
        Grade(id: 5, name: "5th Kup", number: -5),
        Grade(id: 6, name: "4th Kup", number: -4),
        Grade(id: 7, name: "3rd Kup", number: -3),
        Grade(id: 8, name: "2nd Kup", number: -2),
        Grade(id: 9, name: "1st Kup", number: -1),
        Grade(id: 10, name: "1st Degree", number: 1),
        Grade(id: 11, name: "2nd Degree", number: 2),
        Grade(id: 12, name: "3rd Degree", number: 3),
        Grade(id: 13, name: "4th Degree", number: 4),
        Grade(id: 14, name: "5th Degree", number: 5),
        Grade(id: 15, name: "6th Degree", number: 6),
        Grade(id: 16, name: "7th Degree", number: 7),
        Grade(id: 17, name: "8th Degree", number: 8),
        Grade(id: 18, name: "9th Degree", number: 9),
      ];
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<List<Art>?> fetchArts() async {
    try {
      /// Generate a fake response
      return const <Art>[
        Art(id: 1, name: "ITF Tae Kwon Do"),
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

  // Future<List<String>?> fetchClubLocations() async {
  //   try {
  //     /// Generate a fake response
  //     return const [
  //       "London",
  //       "Manchester",
  //       "Birmingham",
  //       "Liverpool",
  //       "Leeds",
  //     ];
  //   } on DioException catch (e) {
  //     sl<Logger>().e(e);
  //     rethrow;
  //   }
  // }

  Future<List<Location>?> fetchClubLocations({String? clubID}) async {
    String url = "/wcra/v1/clubs-configurations?clubID=$clubID";

    try {
      final response = await dio.get(url);

      final data = response.data['club_locations'] as List<dynamic>;

      final lists = data.map((e) => Location.fromJson(e)).toList();

      sl<Logger>().i("Locations: $lists");

      return lists;
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }

  Future<List<Student>?> fetchAllStudentsFromSelectedClub(int clubId) async {
    String url = "/wcra/v1/getstudentlink/?secret_key=${EnvValues.secretKey}";
    url = "$url&clubid=$clubId";

    try {
      final response = await dio.get(url);

      final data = response.data['data'];

      final lists = (data as List)
          .map(
            (e) => Student.fromJson(e),
          )
          .toList();

      return lists;
    } on DioException catch (e) {
      sl<Logger>().e(e);
      rethrow;
    }
  }
}
