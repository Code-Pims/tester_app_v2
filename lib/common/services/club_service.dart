import 'package:dojodex_common/dojdex_models.dart';
import 'package:dojodex_instructor/data/database/database_service.dart';
import 'package:dojodex_instructor/data/database/databases.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';

class ClubService {
  ClubService(this.database);
  final DatabaseService database;

  Future<Club?> getCurrentClub() async {
    final databaseService = sl<DatabaseService>();
    final users = await databaseService.getAll(CurrentClub().name);
    if (users?.isEmpty ?? true) {
      return null;
    }
    return Club.fromJson(users!.first);
  }
}
