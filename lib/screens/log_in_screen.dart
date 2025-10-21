import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
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
  bool _showPwd = false;

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
        _errorMessage = 'DATOS INCORRECTOS';
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
              return Center(
                child: Image.asset(
                  'assets/ojitos.gif',
                  width: 100,
                  height: 100,
                ),
              );
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
                          decoration: const InputDecoration(
                              labelText: 'USUARIO',
                              labelStyle: TextStyle(
                                color: AppTheme.logo,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              )),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPwd,
                          decoration: InputDecoration(
                            labelText: 'CONTRASEÑA',
                            labelStyle: const TextStyle(
                              color: AppTheme.logo,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPwd
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.logo,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPwd = !_showPwd;
                                });
                              },
                            ),
                          ),
                        ),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(AppTheme.logo)),
                          onPressed: _login,
                          child: const Text(
                            'ENTRÁ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    AppTheme.cardColor)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'No tienes cuenta? CREÁ UNA NUEVA!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18),
                            ))
                      ],
                    ));
          })),
      bottomNavigationBar: widget.comingFromOnboarding == true
          ? BottomNavigationBar(
              selectedLabelStyle: const TextStyle(fontSize: 16),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              currentIndex: 0, // mismo control
              onTap: (index) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScaffold(initialIndex: index),
                  ),
                  (route) => false,
                );
              },
              items: [
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/explorar.png',
                      height: 30, // ajustá el tamaño
                      width: 30,
                    ),
                    label: 'Explorar'),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/pincel3.png',
                      height: 24, // ajustá el tamaño
                      width: 24,
                    ),
                    label: 'Crear Plan'),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/solocarita.png',
                      height: 24, // ajustá el tamaño
                      width: 24,
                    ),
                    label: 'Perfil'),
              ],
            )
          : null,
    );
  }
}
