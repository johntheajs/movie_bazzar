import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';

// import 'package:sqflite/sqflite.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = _usernameController.text;
    String password = _passwordController.text;
    String? savedPassword = prefs.getString(username);
    if (savedPassword == null || savedPassword != password) {
      // Show error message
      return;
    }
    // Navigate to MainPage if login successful
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(),
      ),
    );
  }

  Future<void> _performSignup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = _usernameController.text;
    String password = _passwordController.text;
    String reEnterPassword = _reEnterPasswordController.text;
    if (password != reEnterPassword) {
      // Show error message
      return;
    }
    await prefs.setString(username, password);
    // Navigate to LoginPage after successful signup
    setState(() {
      _isLoginMode = true;
    });
  }
}


class MainPage extends StatelessWidget {
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
                      builder: (context) => MoviesPage(),
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
                      builder: (context) => WatchlistPage(),
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
            MoviesPage(),
            WatchlistPage(),
          ],
        ),
      ),
    );
  }
}


class MoviesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Movies Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show AlertDialog for adding a new movie
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddMovieDialog();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class WatchlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Watchlist Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show AlertDialog for adding a new watchlist item
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddWatchlistItemDialog();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddMovieDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Movie'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Year'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Rating'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Genre'),
            ),
            TextFormField(
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
          onPressed: () {
            // Add movie logic
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

class AddWatchlistItemDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Watchlist Item'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Year'),
            ),
            TextFormField(
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
          onPressed: () {
            // Add watchlist item logic
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
