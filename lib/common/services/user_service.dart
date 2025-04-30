import 'package:dojodex_instructor/data/database/database_service.dart';
import 'package:dojodex_instructor/data/database/databases.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/models/user/user.dart';

class UserService {
  UserService(this.database);
  final DatabaseService database;

  Stream<User?> listenToUser() {
    final databaseService = sl<DatabaseService>();
    return databaseService.multipleListen(UserDatabase().name).map(
      (users) {
        if (users.isEmpty) {
          return null;
        }
        return User.fromJson(users.first);
      },
    );
  }

  Future<User?> getUser() async {
    final databaseService = sl<DatabaseService>();
    final users = await databaseService.getAll(UserDatabase().name);
    if (users?.isEmpty ?? true) {
      return null;
    }
    return User.fromJson(users!.first);
  }
}
