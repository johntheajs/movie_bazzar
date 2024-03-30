import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

// Import User model and UserDAO
import 'models/user_model.dart';
import '../dao/user_dao.dart';
import 'models/movie_model.dart'; // Import Movie model
import '../dao/movie_dao.dart'; // Import MovieDAO
import '../helpers/database_helper.dart'; // Import DatabaseHelper
import 'models/movie_watchlist_model.dart'; // Import Movie model
import '../dao/movie_watchlist_dao.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Bazzar',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginMode = true;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _reEnterPasswordController = TextEditingController();

  // Instantiate UserDAO
  final UserDao _userDAO = UserDao();
  int? _userId; // Temporary variable to store the logged-in user's ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _isLoginMode
                      ? _buildLoginForm()
                      : _buildSignupForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      Text(
        'Login',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          _performLogin();
        },
        child: Text('Login'),
      ),
      SizedBox(height: 16),
      TextButton(
        onPressed: () {
          setState(() {
            _isLoginMode = false;
          });
        },
        child: Text('Signup'),
      ),
    ];
  }

  List<Widget> _buildSignupForm() {
    return [
      Text(
        'Signup',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _reEnterPasswordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Re-enter Password',
        ),
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          _performSignup();
        },
        child: Text('Signup'),
      ),
      SizedBox(height: 16),
      TextButton(
        onPressed: () {
          setState(() {
            _isLoginMode = true;
          });
        },
        child: Text('Login'),
      ),
    ];
  }

  Future<void> _performLogin() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    // Retrieve user from database by username
    User? user = await _userDAO.getUserByUsername(username);
    if (user != null && user.password == password) {
      // Store the logged-in user's ID
      _userId = user.id;
      // Navigate to MainPage if login successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(userId: _userId!),
        ),
      );
    } else {
      // Show error message
      _showErrorMessage('Invalid username or password');
    }
  }

  Future<void> _performSignup() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String reEnterPassword = _reEnterPasswordController.text;

    if (password != reEnterPassword) {
      // Show error message
      _showErrorMessage('Passwords do not match');
      return;
    }

    // Check if the username is already taken
    User? existingUser = await _userDAO.getUserByUsername(username);
    if (existingUser != null) {
      // Show error message
      _showErrorMessage('Username already exists');
      return;
    }

    // Insert new user into the database
    User newUser = User(username: username, password: password);
    await _userDAO.insertUser(newUser);

    // Navigate to LoginPage after successful signup
    setState(() {
      _isLoginMode = true;
    });
    _showSuccessMessage('Signup successful! Please login.');
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final int userId;

  MainPage({required this.userId});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Movie Bazzar'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Movies'),
              Tab(text: 'Watchlist'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text('Movies'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to MoviesPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoviesPage(userId: widget.userId),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Watchlist'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to WatchlistPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WatchlistPage(userId: widget.userId),
                    ),
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MoviesPage(userId: widget.userId),
            WatchlistPage(userId: widget.userId),
          ],
        ),
      ),
    );
  }
}

class MoviesPage extends StatefulWidget {
  final int userId;

  MoviesPage({required this.userId});

  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    // Fetch movies associated with the userId from the database using DAO
    _moviesFuture = MovieDAO().getMoviesByUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Movie> movies = snapshot.data ?? [];
            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                Movie movie = movies[index];
                return ListTile(
                  title: Text(movie.title),
                  subtitle: Text('${movie.year} | ${movie.genre}'),
                  onTap: () {
                    _showMovieDetailsDialog(movie);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show AlertDialog for adding a new movie
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddMovieDialog(userId: widget.userId);
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showMovieDetailsDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(movie.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Year: ${movie.year}'),
              Text('Rating: ${movie.rating}'),
              Text('Genre: ${movie.genre}'),
              Text('Description: ${movie.description}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}



class AddMovieDialog extends StatelessWidget {
  final int userId;

  const AddMovieDialog({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Controllers for each input field
    TextEditingController titleController = TextEditingController();
    TextEditingController yearController = TextEditingController();
    TextEditingController ratingController = TextEditingController();
    TextEditingController genreController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return AlertDialog(
      title: Text('Add Movie'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: yearController,
              decoration: InputDecoration(labelText: 'Year'),
            ),
            TextFormField(
              controller: ratingController,
              decoration: InputDecoration(labelText: 'Rating'),
            ),
            TextFormField(
              controller: genreController,
              decoration: InputDecoration(labelText: 'Genre'),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Get text from controllers
            String title = titleController.text;
            int year = int.parse(yearController.text);
            double rating = double.parse(ratingController.text);
            String genre = genreController.text;
            String description = descriptionController.text;

            // Create a Movie object
            Movie movie = Movie(
              userId: userId,
              title: title,
              year: year,
              rating: rating,
              genre: genre,
              description: description,
            );

            // Insert movie into the database
            MovieDAO movieDAO = MovieDAO();
            await movieDAO.insertMovie(movie);

            // Close the dialog
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

class WatchlistPage extends StatefulWidget {
  final int userId;

  const WatchlistPage({required this.userId});

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  late Future<List<MovieWatchlist>> _watchlistItemsFuture;

  @override
  void initState() {
    super.initState();
    _loadWatchlistItems();
  }

  Future<void> _loadWatchlistItems() async {
    // Fetch watchlist items associated with the userId from the database using DAO
    _watchlistItemsFuture = MovieWatchlistDAO().getMovieWatchlistByUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MovieWatchlist>>(
        future: _watchlistItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<MovieWatchlist> watchlistItems = snapshot.data ?? [];
            return ListView.builder(
              itemCount: watchlistItems.length,
              itemBuilder: (context, index) {
                MovieWatchlist watchlistItem = watchlistItems[index];
                return ListTile(
                  title: Text(watchlistItem.title),
                  subtitle: Text('${watchlistItem.year} | ${watchlistItem.genre}'),
                  onTap: () {
                    _showWatchlistItemDetailsDialog(watchlistItem);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show AlertDialog for adding a new watchlist item
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddWatchlistItemDialog(userId: widget.userId);
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showWatchlistItemDetailsDialog(MovieWatchlist watchlistItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(watchlistItem.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Year: ${watchlistItem.year}'),
              Text('Genre: ${watchlistItem.genre}'),
              // Add more details if needed
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class AddWatchlistItemDialog extends StatelessWidget {
  final int userId;

  const AddWatchlistItemDialog({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Controllers for each input field
    TextEditingController titleController = TextEditingController();
    TextEditingController yearController = TextEditingController();
    TextEditingController genreController = TextEditingController();

    return AlertDialog(
      title: Text('Add Watchlist Item'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: yearController,
              decoration: InputDecoration(labelText: 'Year'),
            ),
            TextFormField(
              controller: genreController,
              decoration: InputDecoration(labelText: 'Genre'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Get text from controllers
            String title = titleController.text;
            int year = int.parse(yearController.text);
            String genre = genreController.text;

            // Create a MovieWatchlist object
            MovieWatchlist watchlistItem = MovieWatchlist(
              title: title,
              year: year,
              genre: genre,
              userId: userId,
            );

            // Insert watchlist item into the database
            MovieWatchlistDAO watchlistDAO = MovieWatchlistDAO();
            await watchlistDAO.insertMovieWatchlist(watchlistItem);

            // Close the dialog
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}