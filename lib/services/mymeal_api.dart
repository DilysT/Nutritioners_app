import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutrition_app/services/token_api.dart';

class ApiService {
  static final ApiClient _client = ApiClient();

  static Future<Map<String, dynamic>> getMealsByDate(String date) async {
    final response = await _client.get('api/auth/meals?date=$date');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createDiary(String date) async {
    final response = await _client.post(
      'api/auth/diaries',
      body: {'date': date},
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
    final response = await _client.post(
      'api/auth/meals/$mealId/foods',
      body: {
        'date': date,
        'foodId': foodId,
        'portion': portion,
        'size': size,
      },
    );
    print(response.body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateFoodInMeal({
    required int mealId,
    required int listFoodId,
    required int portion,
    required int size,
    required String date,
  }) async {
    final response = await _client.put(
      'api/auth/meals/$mealId/foods/$listFoodId',
      body: {'date': date, 'portion': portion, 'size': size},
    );
    return jsonDecode(response.body);
  }

  static Future<void> deleteFoodFromMeal({
    required int mealId,
    required int foodId,
    required String date,
  }) async {
    await _client.delete(
      'api/auth/meals/$mealId/foods/$foodId',
      body: {'date': date},
    );
  }

  static Future<Map<String, dynamic>> getAllFoods() async {
    final response = await _client.get('api/auth/foods');
    return jsonDecode(response.body);
  }
}
