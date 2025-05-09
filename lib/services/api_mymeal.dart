// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/auth';
  static const String _token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtYWlsIjoiZGlseXN0QGV4YW1wbGUuY29tIiwiaWF0IjoxNzQ2NTEwMDYzLCJleHAiOjE3NDY1MTM2NjN9.mjWjhnTtC2THmxMPJ5OuLj2tYJ_UkwmP5mGmywjfXbs';

  static Map<String, String> _headers({bool json = false}) {
    final headers = {
      'Authorization': 'Bearer $_token',
    };
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> getMealsByDate(String date) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/meals?date=$date'),
      headers: _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createDiary(String date) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/diaries'),
      headers: _headers(json: true),
      body: jsonEncode({'date': date}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addFoodToMeal({
    required int mealId,
    required int foodId,
    required int portion,
    required int size,
    required String date,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/meals/$mealId/foods'),
      headers: _headers(json: true),
      body: jsonEncode({
        'date': date,
        'foodId': foodId,
        'portion': portion,
        'size': size,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateFoodInMeal({
    required int mealId,
    required int listFoodId,
    required int portion,
    required int size,
    required String date,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/meals/$mealId/foods/$listFoodId'),
      headers: _headers(json: true),
      body: jsonEncode({
        'date': date,
        'portion': portion,
        'size': size,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<void> deleteFoodFromMeal({
    required int mealId,
    required int foodId,
    required String date,
  }) async {
    await http.delete(
      Uri.parse('$_baseUrl/meals/$mealId/foods/$foodId'),
      headers: _headers(json: true),
      body: jsonEncode({'date': date}),
    );
  }

  static Future<Map<String, dynamic>> getAllFoods() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/foods'),
      headers: _headers(),
    );
    return jsonDecode(response.body);
  }
}
