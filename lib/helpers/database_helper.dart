import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'movie_bazaar.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE movie_watchlist(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            title TEXT,
            year INTEGER,
            genre TEXT,
            FOREIGN KEY(userId) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE movies(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            title TEXT,
            year INTEGER,
            rating REAL,
            genre TEXT,
            description TEXT,
            FOREIGN KEY(userId) REFERENCES users(id)
          )
        ''');
      },
      version: 1,
    );
  }
}
