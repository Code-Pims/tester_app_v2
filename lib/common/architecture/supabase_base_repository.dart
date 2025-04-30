import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseBaseRepository {
  final SupabaseClient supabase;

  SupabaseBaseRepository(this.supabase);

  /// static method for tables
  String get messagesTable => 'messages';
  String get lessonScheduleTable => 'lesson_schedules';
  String get attendanceTable => 'attendances';

  /// method for schema
  String get publicSchema => 'public';
  String get privateSchema => 'private';
}
