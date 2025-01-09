import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MovieDetailScreen extends StatefulWidget {
  final String imdbID;

  // Constructor that requires imdbID
  MovieDetailScreen({required this.imdbID});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Map<String, dynamic>> _movieDetails;
  bool isWatched = false;

  // In-memory list to store watched movies (in production, use shared_preferences or database)
  static List<Map<String, dynamic>> watchedMovies = [];

  @override
  void initState() {
    super.initState();
    _movieDetails = _fetchMovieDetails(widget.imdbID);
  }

  // Fetch movie details using IMDb ID
  Future<Map<String, dynamic>> _fetchMovieDetails(String imdbID) async {
    final String apiKey = 'e48b38b2'; // Replace with your actual API key.
    final String baseUrl = 'https://www.omdbapi.com/';
    final url = '$baseUrl?i=$imdbID&apikey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['Response'] == 'True') {
        return data;
      } else {
        throw Exception('Failed to load movie details');
      }
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  void _toggleWatchedStatus(Map<String, dynamic> movie) {
    setState(() {
      isWatched = !isWatched;
      if (isWatched) {
        watchedMovies.add(movie); // Add to watched list
      } else {
        watchedMovies.removeWhere((element) => element['imdbID'] == movie['imdbID']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Detail'),
        actions: [
          IconButton(
            icon: Icon(isWatched ? Icons.check_circle : Icons.check_circle_outline),
            onPressed: () {
              _movieDetails.then((movie) {
                _toggleWatchedStatus(movie);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data?['Response'] != 'True') {
            return Center(child: Text('Movie details not found.'));
          } else {
            final movie = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: movie['Poster'] != 'N/A'
                        ? Image.network(movie['Poster'])
                        : Icon(Icons.movie, size: 200),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    movie['Title'] ?? 'No Title',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 8.0),
                  Text('Year: ${movie['Year'] ?? 'N/A'}'),
                  SizedBox(height: 8.0),
                  Text('Genre: ${movie['Genre'] ?? 'N/A'}'),
                  SizedBox(height: 8.0),
                  Text(
                    'Plot: ${movie['Plot'] ?? 'No plot available.'}',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
