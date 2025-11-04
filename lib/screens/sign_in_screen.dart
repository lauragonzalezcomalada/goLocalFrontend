import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'dart:convert';

import 'package:worldwildprova/screens/onboarding_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
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
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "REGISTRO MANUAL",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.logo),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'NOMBRE',
                        labelStyle: TextStyle(
                          color: AppTheme.logo,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                  TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'EMAIL',
                        labelStyle: TextStyle(
                          color: AppTheme.logo,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                  TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'CONTRASEÑA',
                        labelStyle: TextStyle(
                          color: AppTheme.logo,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      obscureText: true),
                  SizedBox(height: 100),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        registerManually();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.logo,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                    ),
                    child: Text(
                      'SIGUIENTE',
                      style: TextStyle(
                        height: 1,
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
