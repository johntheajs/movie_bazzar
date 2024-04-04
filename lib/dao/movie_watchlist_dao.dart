import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/movie_watchlist_model.dart';
import '../helpers/database_helper.dart';

class MovieWatchlistDAO {
  Future<int> insertMovieWatchlist(MovieWatchlist movieWatchlist) async {
    final Database db = await DatabaseHelper.database;
    return await db.insert(
      'movie_watchlist',
      movieWatchlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MovieWatchlist>> getMovieWatchlistByUserId(int userId) async {
    final Database db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movie_watchlist',
      where: 'userid = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return MovieWatchlist.fromMap(maps[i]);
    });
  }

  Future<int> deleteMovieWatchlistByUserId(int id) async {
    final Database db = await DatabaseHelper.database;
    return await db.delete(
      'movie_watchlist',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
