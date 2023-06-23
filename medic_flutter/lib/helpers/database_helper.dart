import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:medic_flutter/glookose_reading.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  DatabaseHelper.internal();

  Future<Database> initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'glucose.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''
          CREATE TABLE glucose_readings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value REAL,
            dateTime TEXT
          )
          ''',
        );
      },
    );

    return _database!;
  }

  Future<int> addGlucoseReading(GlucoseReading reading) async {
    final db = await database;
    return await db.insert('glucose_readings', reading.toMap());
  }

  Future<List<GlucoseReading>> getGlucoseReadings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('glucose_readings');
    return List.generate(
      maps.length,
      (index) => GlucoseReading.fromMap(maps[index]),
    );
  }

  Future<int> deleteGlucoseReading(int id) async {
    final db = await database;
    return await db.delete(
      'glucose_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
