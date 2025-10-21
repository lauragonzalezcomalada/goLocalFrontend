import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'dart:convert';

import 'package:worldwildprova/screens/onboarding_screen.dart';
import 'package:worldwildprova/widgets/authservice.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registerManually() async {
    final response = await http.post(
      Uri.parse('${Config.serverIp}/signIn/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.login(nameController.text, passwordController.text);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(
              userUuid: data['user_uuid'], name: nameController.text),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Error: ${response.body}');
    }
  }

  /*Future<void> registerWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final account = await googleSignIn.signIn();
      final auth = await account?.authentication;
      final idToken = auth?.idToken;

      if (idToken != null) {
        final response = await http.post(
          Uri.parse('${Config.serverIp}/auth/google/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'idToken': idToken}),
        );

        if (response.statusCode == 200) {
          print('Login con Google exitoso');
        } else {
          print('Error en backend: ${response.body}');
        }
      }
    } catch (e) {
      print('Error al usar Google Sign-In: $e');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrarse')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Registro manual"),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nombre')),
                  TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email')),
                  TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Contraseña'),
                      obscureText: true),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        registerManually();
                      }
                    },
                    child: Text('Registrarse manualmente'),
                  ),
                ],
              ),
            ),
            /*Divider(),
            Text("O registrate con Google"),
            ElevatedButton(
              onPressed: registerWithGoogle,
              child: Text('Continuar con Google'),
            ),*/
          ],
        ),
      ),
    );
  }
}
