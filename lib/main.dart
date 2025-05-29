import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'CRUD App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // Datos para usuarios
  List<Map<String, String>> users = [];
  // Datos para películas
  List<Map<String, dynamic>> movies = [];

  // Métodos para usuarios
  void addUser(String login, String password) {
    users.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'login': login,
      'password': password,
    });
    notifyListeners();
  }

  void updateUser(String id, String login, String password) {
    final index = users.indexWhere((user) => user['id'] == id);
    if (index != -1) {
      users[index] = {
        'id': id,
        'login': login,
        'password': password,
      };
      notifyListeners();
    }
  }

  void deleteUser(String id) {
    users.removeWhere((user) => user['id'] == id);
    notifyListeners();
  }

  // Métodos para películas
  void addMovie(String nombre, String clasificacion, String director) {
    movies.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'nombre': nombre,
      'clasificacion': clasificacion,
      'director': director,
    });
    notifyListeners();
  }

  void updateMovie(
      String id, String nombre, String clasificacion, String director) {
    final index = movies.indexWhere((movie) => movie['id'] == id);
    if (index != -1) {
      movies[index] = {
        'id': id,
        'nombre': nombre,
        'clasificacion': clasificacion,
        'director': director,
      };
      notifyListeners();
    }
  }

  void deleteMovie(String id) {
    movies.removeWhere((movie) => movie['id'] == id);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = UsersPage();
        break;
      case 1:
        page = MoviesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      label: Text('Usuarios'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.movie),
                      label: Text('Películas'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedUserId;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _loginController.clear();
    _passwordController.clear();
    _selectedUserId = null;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'CRUD de Usuarios',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _loginController,
            decoration: InputDecoration(
              labelText: 'Login',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_loginController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty) {
                    if (_selectedUserId == null) {
                      appState.addUser(
                          _loginController.text, _passwordController.text);
                    } else {
                      appState.updateUser(_selectedUserId!,
                          _loginController.text, _passwordController.text);
                    }
                    _clearFields();
                  }
                },
                child: Text(_selectedUserId == null ? 'Agregar' : 'Actualizar'),
              ),
              ElevatedButton(
                onPressed: _clearFields,
                child: Text('Limpiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: appState.users.length,
              itemBuilder: (context, index) {
                final user = appState.users[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(user['login'] ?? ''),
                    subtitle: Text('ID: ${user['id']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _selectedUserId = user['id'];
                              _loginController.text = user['login'] ?? '';
                              _passwordController.text = user['password'] ?? '';
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            appState.deleteUser(user['id']!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MoviesPage extends StatefulWidget {
  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _clasificacionController =
      TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  String? _selectedMovieId;

  @override
  void dispose() {
    _nombreController.dispose();
    _clasificacionController.dispose();
    _directorController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _nombreController.clear();
    _clasificacionController.clear();
    _directorController.clear();
    _selectedMovieId = null;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'CRUD de Películas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _clasificacionController,
            decoration: InputDecoration(
              labelText: 'Clasificación',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _directorController,
            decoration: InputDecoration(
              labelText: 'Director',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_nombreController.text.isNotEmpty &&
                      _clasificacionController.text.isNotEmpty &&
                      _directorController.text.isNotEmpty) {
                    if (_selectedMovieId == null) {
                      appState.addMovie(
                          _nombreController.text,
                          _clasificacionController.text,
                          _directorController.text);
                    } else {
                      appState.updateMovie(
                          _selectedMovieId!,
                          _nombreController.text,
                          _clasificacionController.text,
                          _directorController.text);
                    }
                    _clearFields();
                  }
                },
                child:
                    Text(_selectedMovieId == null ? 'Agregar' : 'Actualizar'),
              ),
              ElevatedButton(
                onPressed: _clearFields,
                child: Text('Limpiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: appState.movies.length,
              itemBuilder: (context, index) {
                final movie = appState.movies[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(movie['nombre'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${movie['id']}'),
                        Text('Clasificación: ${movie['clasificacion']}'),
                        Text('Director: ${movie['director']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _selectedMovieId = movie['id'];
                              _nombreController.text = movie['nombre'] ?? '';
                              _clasificacionController.text =
                                  movie['clasificacion'] ?? '';
                              _directorController.text =
                                  movie['director'] ?? '';
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            appState.deleteMovie(movie['id']!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
