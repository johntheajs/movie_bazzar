class MovieWatchlist {
  int ? id; // Change to non-final and nullable
  final String title;
  final int year;
  final String genre;
  final int userId;

  MovieWatchlist({
    this.id, // Initialize to 0
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
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Don't include id in the map
      'title': title,
      'year': year,
      'genre': genre,
      'userId': userId,
    };
  }
}
