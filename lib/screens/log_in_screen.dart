import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'dart:convert';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/screens/sign_in_screen.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';

class LogInScreen extends StatefulWidget {
  bool comingFromOnboarding;

  final String? redirectTo;

  LogInScreen({required this.comingFromOnboarding, this.redirectTo, super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = ''; // Para mostrar el mensaje de error

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(username, password);

    if (success) {
      //No hace falta hacer Navigation.push, porque el Widget es reactivo
      setState(() {
        _errorMessage = '';
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            notFromMainScaffold: true,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Datos incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context); // Escucha cambios

    return Scaffold(
      body: FutureBuilder(
          future: authService.isLoggedIn(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              //mentre carrega
              return const Center(child: CircularProgressIndicator());
            }
            final isLoggedIn = snapshot.data!;
            return isLoggedIn
                ? ProfileScreen()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                        ),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _login,
                          child: const Text('Log In'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInScreen(),
                                ),
                              );
                            },
                            child: Text('No tienes cuenta? Create una nueva!'))
                      ],
                    ));
          })),
      bottomNavigationBar: widget.comingFromOnboarding == true
          ? BottomNavigationBar(
              currentIndex: 0, // mismo control
              onTap: (index) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScaffold(
                      initialIndex: index,
                    ),
                  ),
                );
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.place), label: 'Lugares'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.brush), label: 'Crear plan'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Perfil'),
              ],
            )
          : null,
    );
  }
}
