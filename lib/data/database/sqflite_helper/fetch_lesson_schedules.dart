import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FetchLessonSchedules {
  static final FetchLessonSchedules _instance = FetchLessonSchedules._internal();
  static Database? _database;

  factory FetchLessonSchedules() => _instance;

  FetchLessonSchedules._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'lesson_schedules.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lesson_schedules (
            id INTEGER PRIMARY KEY,
            club_id INTEGER,
            class_name TEXT,
            location_name TEXT,
            club_address TEXT,
            day_index INTEGER,
            start_time TEXT,
            end_time TEXT,
            min_age INTEGER,
            max_age INTEGER,
            min_grade INTEGER,
            max_grade INTEGER,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertLessonSchedule(LessonSchedule schedule) async {
    final db = await database;
    return await db.insert('lesson_schedules', schedule.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LessonSchedule>> getLessonSchedules(int clubId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lesson_schedules',
      where: 'club_id = ?',
      whereArgs: [clubId],
    );
    return maps.map((e) => LessonSchedule.fromJson(e)).toList();
  }

  Future<void> clearLessonSchedules(int clubId) async {
    final db = await database;
    await db.delete('lesson_schedules', where: 'club_id = ?', whereArgs: [clubId]);
  }
}