class Movie {
  final String imdbID;
  final String title;
  final String year;
  final String poster;

  Movie({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.poster,
  });

  // Create a Movie from JSON data
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      imdbID: json['imdbID'] ?? '', // Default to empty string if missing
      title: json['Title'] ?? '',   // Default to empty string if missing
      year: json['Year'] ?? '',     // Default to empty string if missing
      poster: json['Poster'] ?? 'N/A', // Default to 'N/A' if no poster
    );
  }
}
