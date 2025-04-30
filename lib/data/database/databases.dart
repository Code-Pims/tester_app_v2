import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_common/models/flash_card/flash_card.dart';
import 'package:dojodex_common/models/user/user.dart';

abstract class BaseDatabaseConstants<T> {
  String get name;
}

class UserDatabase extends BaseDatabaseConstants {
  @override
  String get name => 'user';

  List<Map<String, dynamic>>? valuesToMap(
    List<FlashCard> values,
  ) {
    return values.map((e) {
      return e.toJson();
    }).toList();
  }
}

class CurrentClub extends BaseDatabaseConstants {
  @override
  String get name => 'current_club';

  List<Map<String, dynamic>>? valuesToMap(
    List<Club> values,
  ) {
    return values.map((e) {
      return e.toJson();
    }).toList();
  }
}

class MessagesTable extends BaseDatabaseConstants {
  @override
  String get name => 'messages';

  List<Map<String, dynamic>>? valuesToMap(
    List<User> values,
  ) {
    return values.map((e) {
      return e.toJson();
    }).toList();
  }
}
