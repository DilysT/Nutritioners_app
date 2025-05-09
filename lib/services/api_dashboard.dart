import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_data.dart';

class ApiDashboardService {
  static const String _baseUrl = 'http://172.30.157.246:3000';
  static const String _token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtYWlsIjoiZGlseXN0QGV4YW1wbGUuY29tIiwiaWF0IjoxNzQ2NjEwNzI5LCJleHAiOjE3NDY2MTQzMjl9.k7BYxjFVZNqcpUUhQ62BR_thNv69bEPwy9f5WZWYnDU'; // Có thể thay bằng token lấy từ local storage sau

  static Map<String, String> _headers({bool json = false}) {
    final headers = {
      'Authorization': 'Bearer $_token',
    };
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }
  static Future<Map<String, dynamic>> fetchDashboardData(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/diaries/meals?date=$date'),
        headers: _headers(),
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in fetchDashboardData: $e");
      throw e;
    }
  }

}
