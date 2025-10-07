import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';

import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:worldwildprova/config.dart';
import 'dart:convert';

class AuthService with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  DateTime? _accessTokenExpiry;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  UserProfile? _currentUser;

  // Método para hacer login y obtener los tokens
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${Config.serverIp}/token/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      _accessToken = responseBody['access'];
      _refreshToken = responseBody['refresh'];

      _accessTokenExpiry = JwtDecoder.getExpirationDate(_accessToken!);

      await _saveTokens(_accessToken!, _refreshToken!, _accessTokenExpiry!);
      await getUserProfile(_accessToken);
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

  //(borrar los tokens)
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

    final response =
        await http.post(Uri.parse('${Config.serverIp}/token/refresh/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'refresh': refreshToken,
            }));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _saveNewAccessToken(data['access']);
    } else {
      print('Error al refrescar el token: ${response.statusCode}');
    }
  }

  Future<UserProfile?> getUserProfile(String? token) async {
    final accessToken = await getAccessToken();
    if (token == null) return null;

    final response = await http.get(
        Uri.parse('${Config.serverIp}/user/profile/'),
        headers: {'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      _currentUser = UserProfile.fromJson(data);
      notifyListeners();
      return _currentUser;
    } else {
      return null;
    }
  }

  UserProfile? get currentUser => _currentUser;
}
