import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

class MoviesPage extends StatelessWidget {
  final int userId;

  MoviesPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Movie>>(
        future: MovieDAO().getMoviesByUserId(userId),
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
                    _showMovieDetailsDialog(context, movie);
                  },
                  onLongPress: () {
                    _showDeleteConfirmationDialog(context, movie.id ?? 0);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddMovieDialog(userId: userId);
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showMovieDetailsDialog(BuildContext context, Movie movie) {
  // Controllers for each input field
  TextEditingController titleController = TextEditingController(text: movie.title);
  TextEditingController yearController = TextEditingController(text: movie.year.toString());
  TextEditingController ratingController = TextEditingController(text: movie.rating.toString());
  TextEditingController genreController = TextEditingController(text: movie.genre);
  TextEditingController descriptionController = TextEditingController(text: movie.description);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(movie.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Year: ${movie.year}'),
              Text('Genre: ${movie.genre}'),
              Text('Description: ${movie.description}'),
              SizedBox(height: 16), // Add some spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddMovieDialog(
                            userId: movie.userId,
                            movie: movie,
                          );
                        },
                      );
                    },
                    child: Text('Update'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _showDeleteConfirmationDialog(BuildContext context, int movieId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Movie?'),
          content: Text('Are you sure you want to delete this movie?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteMovie(context, movieId);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMovie(BuildContext context, int movieId) async {
    await MovieDAO().deleteMovie(movieId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Movie deleted successfully'),
      ),
    );
    Navigator.of(context).pop(); // Close delete confirmation dialog
  }
}

class WatchlistPage extends StatefulWidget {
  final int userId;

  WatchlistPage({required this.userId});

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  late Future<List<MovieWatchlist>> _watchlistItemsFuture;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadWatchlistItems();
  }

  Future<void> _initializeNotifications() async {
    // Initialize the notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: _onSelectNotification,
    );
  }

  Future<dynamic> _onSelectNotification(String? payload) async {
    // Handle notification selection
    print('Notification selected: $payload');
  }

  Future<void> _loadWatchlistItems() async {
    _watchlistItemsFuture =
        MovieWatchlistDAO().getMovieWatchlistByUserId(widget.userId);
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
                    _showWatchlistItemDetailsDialog(context, watchlistItem);
                  },
                  onLongPress: () {
                    _showDeleteConfirmationDialog(context, watchlistItem.id!);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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

  void _showWatchlistItemDetailsDialog(
      BuildContext context, MovieWatchlist watchlistItem) {
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
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _scheduleReminder(watchlistItem);
                Navigator.of(context).pop();
              },
              child: Text('Remind'),
            ),
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

  void _showDeleteConfirmationDialog(BuildContext context, int watchlistItemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Watchlist Item?'),
          content: Text('Are you sure you want to delete this watchlist item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteWatchlistItem(context, watchlistItemId);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWatchlistItem(BuildContext context, int watchlistItemId) async {
    await MovieWatchlistDAO().deleteMovieWatchlistByUserId(watchlistItemId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Watchlist item deleted successfully'),
      ),
    );
    _loadWatchlistItems();
    Navigator.of(context).pop(); // Close delete confirmation dialog
  }

  void _scheduleReminder(MovieWatchlist watchlistItem) async {
    String movieDetails =
        '${watchlistItem.title}, ${watchlistItem.year}, ${watchlistItem.genre}';
    await _showNotification('Watch Now', movieDetails);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('reminder_channel', 'Reminders',
            // 'Channel for reminders',
            importance: Importance.high, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification title
      body, // Notification body
      platformChannelSpecifics, // Notification details
      payload: 'Reminder Payload', // Optional payload
    );
  }
}


class AddMovieDialog extends StatelessWidget {
  final int userId;
  final Movie? movie; // Nullable Movie object

  const AddMovieDialog({required this.userId, this.movie});

  @override
  Widget build(BuildContext context) {
    // Controllers for each input field
    TextEditingController titleController = TextEditingController();
    TextEditingController yearController = TextEditingController();
    TextEditingController ratingController = TextEditingController();
    TextEditingController genreController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    if (movie != null) {
      // If movie object is provided, fill the text fields with movie details
      titleController.text = movie!.title;
      yearController.text = movie!.year.toString();
      ratingController.text = movie!.rating.toString();
      genreController.text = movie!.genre;
      descriptionController.text = movie!.description;
    }

    return AlertDialog(
      title: Text(movie != null ? 'Update Movie' : 'Add Movie'),
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
            Movie updatedMovie = Movie(
              id: movie?.id, // Retain the original ID
              userId: userId,
              title: title,
              year: year,
              rating: rating,
              genre: genre,
              description: description,
            );

            // If movie object is provided, update the movie
            // Otherwise, insert a new movie
            MovieDAO movieDAO = MovieDAO();
            if (movie != null) {
              await movieDAO.updateMovie(updatedMovie);
            } else {
              await movieDAO.insertMovie(updatedMovie);
            }

            // Close the dialog
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
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