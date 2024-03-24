import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/movie_model.dart';
import '../helpers/database_helper.dart';

class MovieDAO {
  Future<int> insertMovie(Movie movie) async {
    final Database db = await DatabaseHelper.database;
    return await db.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Movie>> getMoviesByUserId(int userId) async {
    final Database db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Movie.fromMap(maps[i]);
    });
  }

  Future<int> deleteMovie(int id) async {
    final Database db = await DatabaseHelper.database;
    return await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
