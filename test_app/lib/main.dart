import 'package:flutter/material.dart';

void main() {
  runApp(MovieApp());
}

class Movie {
  String title;
  int? rating;

  Movie(this.title, {this.rating});
}

class MovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список фильмов',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final List<Movie> _movies = [];
  final TextEditingController _controller = TextEditingController();

  void _addMovie() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _movies.add(Movie(_controller.text));
        _controller.clear();
      });
    }
  }

  void _updateMovie(Movie movie, int? rating) {
    setState(() {
      movie.rating = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Мои фильмы"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Введите название фильма",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addMovie,
                child: Text("Добавить"),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _movies.isEmpty
                    ? Text("Список пуст")
                    : ListView.builder(
                  itemCount: _movies.length,
                  itemBuilder: (context, index) {
                    final movie = _movies[index];
                    return ListTile(
                      title: Row(
                        children: [
                          // название фильма
                          Expanded(
                            child: Text(
                              movie.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),

                          if (movie.rating != null)
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < movie.rating! ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),
                        ],
                      ),
                      onTap: () async {
                        final updatedRating = await Navigator.push<int?>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: movie),
                          ),
                        );
                        if (updatedRating != null) {
                          _updateMovie(movie, updatedRating);
                        }
                      },
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool watched = false;
  bool favorite = false;
  String selectedGenre = "Драма";
  final TextEditingController _commentController = TextEditingController();
  int? selectedRating;

  final List<String> genres = ["Драма", "Комедия", "Боевик", "Фантастика", "Хоррор"];
  final List<int> ratings = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    selectedRating = widget.movie.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Информация о фильме")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              widget.movie.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Image.network(
              "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.disney.com.au%2Fmarvel&psig=AOvVaw3RnzlaX_IkmjOIy5R6zPNK&ust=1758261918309000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCODroZrS4Y8DFQAAAAAdAAAAABAE",
              height: 200,
              fit: BoxFit.contain
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text("Смотрел: "),
                Switch(
                  value: watched,
                  onChanged: (value) => setState(() => watched = value),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: favorite,
                  onChanged: (value) => setState(() => favorite = value!),
                ),
                Text("Добавить в избранное"),
              ],
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: "Ваш комментарий",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedGenre,
              items: genres.map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (value) => setState(() => selectedGenre = value!),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text("Оценка: "),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: selectedRating,
                  hint: Text("Выберите"),
                  items: ratings.map((r) {
                    return DropdownMenuItem(value: r, child: Text("$r"));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRating = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedRating);
              },
              child: Text("Назад"),
            ),
          ],
        ),
      ),
    );
  }
}
