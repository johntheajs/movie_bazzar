class Movie {
  int id;
  int userId; // Foreign key referencing User
  String title;
  int year;
  double rating;
  String genre;
  String description;

  Movie({
    required this.id,
    required this.userId,
    required this.title,
    required this.year,
    required this.rating,
    required this.genre,
    required this.description,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      year: map['year'],
      rating: map['rating'],
      genre: map['genre'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'year': year,
      'rating': rating,
      'genre': genre,
      'description': description,
    };
  }
}
