import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteAttendeesList {
  static final SqfliteAttendeesList _instance =
      SqfliteAttendeesList._internal();

  factory SqfliteAttendeesList() => _instance;
  static Database? _database;

  SqfliteAttendeesList._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'attendees.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE attendees (
            id INTEGER PRIMARY KEY,
            lesson_sched_id INTEGER,
            student_id INTEGER,
            club_id INTEGER,
            on_time TEXT,
            last_session_date TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    final db = await database;
    return await db.insert('attendees', attendance,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAttendance() async {
    final db = await database;
    return await db.query('attendees');
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('attendees');
  }
}
