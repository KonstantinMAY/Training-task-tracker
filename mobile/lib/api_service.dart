import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Для Android-эмулятора. Для Windows desktop адрес будет 127.0.0.1.
  static const String baseUrl = 'http://10.0.2.2:8000';

  static String? token;

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');
  }

  static Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static dynamic decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
      return null;
    }

    final data = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data is Map ? data['detail'] ?? 'Ошибка сервера' : 'Ошибка сервера',
      );
    }

    return data;
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    return _authenticate('/api/auth/register', email, password);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return _authenticate('/api/auth/login', email, password);
  }

  static Future<Map<String, dynamic>> _authenticate(
    String endpoint,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = decodeResponse(response) as Map<String, dynamic>;
    token = data['access_token']?.toString();

    if (token == null || token!.isEmpty) {
      throw Exception('Сервер не вернул токен авторизации.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token!);

    return data;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: authHeaders,
    );
    return decodeResponse(response) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/tasks'),
      headers: authHeaders,
    );
    return decodeResponse(response) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createTask({
    required String title,
    String description = '',
    required String priority,
    String? deadline,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tasks'),
      headers: authHeaders,
      body: jsonEncode({
        'title': title,
        'description': description,
        'priority': priority,
        'deadline': deadline,
      }),
    );
    return decodeResponse(response) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateTask(
    String id, {
    required String title,
    String description = '',
    required String priority,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/tasks/$id'),
      headers: authHeaders,
      body: jsonEncode({
        'title': title,
        'description': description,
        'priority': priority,
      }),
    );
    return decodeResponse(response) as Map<String, dynamic>;
  }

  static Future<void> updateTaskStatus(String id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/tasks/$id/status'),
      headers: authHeaders,
      body: jsonEncode({'status': status}),
    );
    decodeResponse(response);
  }

  static Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/tasks/$id'),
      headers: authHeaders,
    );
    decodeResponse(response);
  }

  static Future<void> logout() async {
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: authHeaders,
        );
      } catch (_) {
        // Даже если сервер недоступен, локальную сессию всё равно завершаем.
      }
    }

    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
