import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class UpdateAttendeesOffline {
  static Database? _database;
  static const String tableName = 'offline_attendance';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'offline_attendance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY,
            lesson_sched_id INTEGER,
            student_id INTEGER,
            club_id INTEGER,
            on_time TEXT,
            last_session_date TEXT,
            created_at TEXT,
            is_uploaded INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertOfflineData(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(tableName, data);
  }

  Future<List<Map<String, dynamic>>> getOfflineData() async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<void> clearOfflineData() async {
    final db = await database;
    await db.delete(tableName);
  }
}
