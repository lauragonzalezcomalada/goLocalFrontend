import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import 'package:worldwildprova/models_fromddbb/userprofile.dart'; // Necesario para convertir JSON a objetos

class AuthService with ChangeNotifier {
  //URL per a tenir el token d'autentificació
  static const String _apiUrl = 'http://192.168.0.17:8000/api/';
  // Instancia de FlutterSecureStorage para guardar el token de forma segura
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  DateTime?
      _accessTokenExpiry; // el temps d'expiració de l'access token, per evitar errors d'401 Unauthorised

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // Método para hacer login y obtener los tokens
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(_apiUrl + 'token/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      _accessToken = responseBody['access'];
      _refreshToken = responseBody['refresh'];

      _accessTokenExpiry = JwtDecoder.getExpirationDate(_accessToken!);

      // Guardar los tokens de forma segura
      await _saveTokens(_accessToken!, _refreshToken!, _accessTokenExpiry!);

      // Notificar a los oyentes (por ejemplo, la UI)
      notifyListeners();

      return true;
    } else {
      return false;
    }
  }

  // Método para guardar los tokens en el almacenamiento seguro
  Future<void> _saveTokens(
      String accessToken, String refreshToken, DateTime expiry) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(
        key: 'access_token_expiry', value: expiry.toIso8601String());
  }

  //Mètode per actualitzar el valor del access_token
  Future<void> _saveNewAccessToken(String accessToken) async {
    _accessToken = accessToken;
    _accessTokenExpiry = JwtDecoder.getExpirationDate(accessToken);
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(
        key: 'access_token_expiry',
        value: _accessTokenExpiry!.toIso8601String());
  }

  // Método para obtener el token de acceso (si está disponible)
  Future<String?> getAccessToken() async {
    final accessToken = await _storage.read(key: 'access_token');
    final expiryString = await _storage.read(key: 'access_token_expiry');

    if (accessToken != null && expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        await refreshAccessToken();
        return await _storage.read(key: 'access_token');
      }
      return accessToken;
    }
    return null;
  }

  // Método para obtener el token de refresh (si está disponible)
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Método para verificar si el usuario está logueado
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Método para hacer logout (borrar los tokens)
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'access_token_expiry');

    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiry = null;

    // Notificar a los oyentes de la UI
    notifyListeners();
  }

  Future<void> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return;

    print('apiurl');
    print(_apiUrl);
    print(refreshToken);

    final response = await http.post(Uri.parse(_apiUrl + 'token/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _saveNewAccessToken(data['access']);
      // Procesar el nuevo access token
      //_saveTokens(String accessToken, String refreshToken)
    } else {
      print('Error al refrescar el token: ${response.statusCode}');
    }
  }

  Future<UserProfile?> getUserProfile(String? token) async {
    final accessToken = await getAccessToken();
    if (token == null) return null;

    final response = await http.get(Uri.parse(_apiUrl + 'user/profile/'),
        headers: {'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data);
    } else {
      return null;
    }
  }
}
