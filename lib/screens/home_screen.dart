import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';  // Import MovieDetailScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MovieService _movieService;
  late Future<List<Movie>> _popularMovies;
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _movieService = MovieService();
    _popularMovies = _movieService.fetchPopularMovies();
  }

  // Function to search for movies
  void _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = true;
      });
      List<Movie> results = await _movieService.searchMoviesAndShows(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Show search bar when search icon is tapped
              showSearch(
                context: context,
                delegate: MovieSearchDelegate(_searchMovies),
              );
            },
          ),
        ],
      ),
      body: _isSearching
          ? Center(child: CircularProgressIndicator())
          : _searchResults.isNotEmpty
              ? ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final movie = _searchResults[index];
                    return MovieCard(movie: movie);
                  },
                )
              : FutureBuilder<List<Movie>>(
                  future: _popularMovies,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No popular movies found"));
                    } else {
                      final movies = snapshot.data!;
                      return ListView.builder(
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return MovieCard(movie: movie);
                        },
                      );
                    }
                  },
                ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  final Function(String) searchMovies;

  MovieSearchDelegate(this.searchMovies);

  @override
  String? get searchFieldLabel => 'Search for movies or TV shows';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          searchMovies(query);  // Reset search results when cleared
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);  // Close the search screen
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Trigger the search when results are displayed
    searchMovies(query);
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: MovieService().searchMoviesAndShows(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return Center(child: Text('No results found'));
        } else {
          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(movie: movie);
            },
          );
        }
      },
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(movie.title),
      subtitle: Text(movie.year),
      leading: movie.poster != 'N/A'
          ? Image.network(movie.poster)
          : Icon(Icons.movie),
      onTap: () {
        // Navigate to MovieDetailScreen when a movie is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(imdbID: movie.imdbID),
          ),
        );
      },
    );
  }
}
