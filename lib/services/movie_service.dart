import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String _apiKey = 'e48b38b2'; // Replace with your actual API key.
  static const String _baseUrl = 'https://www.omdbapi.com/';

  // Fetch popular movies (This is just a mock example, adjust based on actual API)
  Future<List<Movie>> fetchPopularMovies() async {
    final url = '$_baseUrl?s=movie&type=movie&apikey=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Check if the 'Search' key exists and is not null
        if (data['Search'] != null) {
          final List movies = data['Search'];
          return movies.map((movieData) => Movie.fromJson(movieData)).toList();
        } else {
          return []; // Return an empty list if no movies found
        }
      } else {
        throw Exception('Failed to load popular movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load popular movies: $e');
    }
  }

  // Search for movies based on the query
  Future<List<Movie>> searchMoviesAndShows(String query) async {
    final url = '$_baseUrl?s=$query&type=movie&apikey=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Check if the 'Search' key exists and is not null
        if (data['Search'] != null) {
          final List movies = data['Search'];
          return movies.map((movieData) => Movie.fromJson(movieData)).toList();
        } else {
          return []; // Return an empty list if no search results
        }
      } else {
        throw Exception('Failed to search movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }
}
