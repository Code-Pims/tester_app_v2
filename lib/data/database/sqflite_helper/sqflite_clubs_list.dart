import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteClubsList {
  static final SqfliteClubsList _instance = SqfliteClubsList._internal();

  factory SqfliteClubsList() => _instance;
  static Database? _database;

  SqfliteClubsList._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'clubs.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clubs (
            id INTEGER PRIMARY KEY,
            instructor_id INTEGER,
            title TEXT,
            description TEXT,
            cluburl TEXT,
            email TEXT,
            website TEXT,
            primary_address TEXT,
            timetable TEXT,
            imageurl TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertClub(Map<String, dynamic> club) async {
    final db = await database;
    return await db.insert('clubs', club,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getClubs() async {
    final db = await database;
    return await db.query('clubs');
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('clubs');
  }
}
