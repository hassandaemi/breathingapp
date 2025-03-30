import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'breathly_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mood TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Save mood to database
  Future<int> saveMood(String mood) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();

    final Map<String, dynamic> moodData = {
      'mood': mood,
      'timestamp': timestamp,
    };

    return await db.insert('moods', moodData);
  }

  // Get all moods
  Future<List<Map<String, dynamic>>> getMoods() async {
    final db = await database;
    return await db.query('moods', orderBy: 'timestamp DESC');
  }
}
