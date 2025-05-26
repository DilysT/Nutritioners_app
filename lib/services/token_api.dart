import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final String? baseUrl = dotenv.env['API_URL'];

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    print(token);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$path');
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$path');
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$path');
    return http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path, {Object? body}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$path');
    // Nếu API của bạn yêu cầu body trong DELETE (một số không cần)
    return http.delete(url, headers: headers, body: body != null ? jsonEncode(body) : null);
  }
}
