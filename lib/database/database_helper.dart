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
      version: 2,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
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

    await db.execute('''
      CREATE TABLE exercise_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        technique TEXT NOT NULL,
        date TEXT NOT NULL,
        color INTEGER NOT NULL,
        iconName TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE exercise_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          technique TEXT NOT NULL,
          date TEXT NOT NULL,
          color INTEGER NOT NULL,
          iconName TEXT NOT NULL
        )
      ''');
    }
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

  // Save exercise history
  Future<int> saveExerciseHistory(Map<String, dynamic> exerciseData) async {
    final db = await database;
    return await db.insert('exercise_history', exerciseData);
  }

  // Get exercise history
  Future<List<Map<String, dynamic>>> getExerciseHistory(
      {int limit = 10}) async {
    final db = await database;
    return await db.query(
      'exercise_history',
      orderBy: 'date DESC',
      limit: limit,
    );
  }
}
