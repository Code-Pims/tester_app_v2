import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteStudentsList {
  static final SqfliteStudentsList _instance = SqfliteStudentsList._internal();

  factory SqfliteStudentsList() => _instance;
  static Database? _database;

  SqfliteStudentsList._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'students.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY,
            user_id TEXT,
            student_name TEXT,
            student_status TEXT,
            current_grade TEXT,
            dob TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert('students', student,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query('students');
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('students');
  }
}
