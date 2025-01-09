// lib/screens/watched_movies_screen.dart

import 'package:flutter/material.dart';
import 'movie_detail_screen.dart'; // Import movie details screen to access watchedMovies list

class WatchedMoviesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Watched Movies')),
      body: ListView.builder(
        itemCount: MovieDetailScreen.watchedMovies.length,
        itemBuilder: (context, index) {
          final movie = MovieDetailScreen.watchedMovies[index];
          return ListTile(
            title: Text(movie['Title'] ?? 'No Title'),
            subtitle: Text(movie['Year'] ?? 'N/A'),
            leading: movie['Poster'] != 'N/A'
                ? Image.network(movie['Poster'], width: 50, height: 50)
                : Icon(Icons.movie),
          );
        },
      ),
    );
  }
}
