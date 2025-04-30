import 'package:dojodex_common/models/attendance/attendance.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';

import '../../data/database/sqflite_helper/update_attendees_offline.dart';
import '../../dependencies/dependency_manager.dart';
import '../architecture/supabase_base_repository.dart';

class SyncServiceSupabase extends SupabaseBaseRepository {
  final UpdateAttendeesOffline updateAttendeesLocalDB =
      UpdateAttendeesOffline();

  SyncServiceSupabase(super.supabase);

  Future<void> monitorConnection() async {
    var connectivityResult = await InternetConnection().hasInternetAccess;
    if (connectivityResult) await syncAttendance();
  }

  Future<void> syncAttendance() async {
    final unsyncedData = await updateAttendeesLocalDB.getOfflineData();
    if (unsyncedData.isNotEmpty) {
      final logger = sl<Logger>();
      await supabase.from(attendanceTable).delete().neq('id', 0);

      List<Attendance> attendanceList =
          unsyncedData.map((data) => Attendance.fromJson(data)).toList();

      logger
          .i('Inserting multiple attendees in syncAttendance $attendanceList');
      await supabase.from(attendanceTable).insert(attendanceList
          .map(
            (e) => e.toJson()
              ..remove('id')
              ..remove('created_at')
              ..remove('last_session_date')
              ..remove('is_uploaded'),
          )
          .toList());

      await updateAttendeesLocalDB.clearOfflineData();
    }
  }
}
