import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = dotenv.get('BACKEND_URL');
  final logger = Logger();

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String? token = data['data']['access_token'];

      if (token == null) {
        logger.e("Login failed: ${response.body}");

        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', token);

      return true;
    }

    return false;
  }

  Future<bool> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    logger.i("TOKEN: $token");

    if (token == null) return false;

    final response = await http.get(
      Uri.parse('$baseUrl/api/me'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    logger.i("STATUS: ${response.statusCode}");
    logger.i("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    }

    if (response.statusCode == 401) {
      await logout();
      return false;
    }

    return false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
  }
}
