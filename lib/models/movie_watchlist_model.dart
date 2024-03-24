import 'package:flutter/material.dart';

class MovieWatchlist {
  final int id;
  final String title;
  final int year;
  final String genre;
  final int userId; // Assuming there's a userId associated with the watchlist

  MovieWatchlist({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.userId,
  });

  factory MovieWatchlist.fromMap(Map<String, dynamic> map) {
    return MovieWatchlist(
      id: map['id'],
      title: map['title'],
      year: map['year'],
      genre: map['genre'],
      userId: map['user_id'], // Adjust the key according to your database schema
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'genre': genre,
      'user_id': userId, // Adjust the key according to your database schema
    };
  }
}
