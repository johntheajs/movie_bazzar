import 'package:flutter/material.dart';

class MovieWatchlist {
  int? id;
  String title;
  int year;
  String genre;
  int userId;

  MovieWatchlist({
    this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.userId,
  });

  factory MovieWatchlist.fromMap(Map<String, dynamic> map) {
    return MovieWatchlist(
      id: map['id'] as int?,
      title: map['title'] as String,
      year: map['year'] as int,
      genre: map['genre'] as String,
      userId: map['userid'] as int, // Adjust the key according to your database schema
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'genre': genre,
      'userid': userId, // Adjust the key according to your database schema
    };
  }
}
