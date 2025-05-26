import 'package:http/http.dart' as http;
import 'package:nutrition_app/services/token_api.dart';
import 'dart:convert';
import '../../../models/setting_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiClient _client = ApiClient();

  static Future<UserData> getUserInformation() async {
    final response = await _client.get('api/auth/users');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return UserData.fromJson(decoded);
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  static Future<bool> updateUserInformation({
    required String name,
    required String email,
    required String password,
    required String newPassword,
    required double weight,
    required double height,
    required String activityLevel,
    required String gender,
    required String birthday,
    required double weightGoal,
    required String goalType,
  }) async {

    final response = await _client.put('api/auth/users',body:{
      "name": name,
      "email": email,
      "password": password,
      "newPassword": newPassword,
      "weight": weight,
      "height": height,
      "activity_level": activityLevel,
      "gender": gender,
      "birthday": birthday,
      "weight_goal": weightGoal,
      "goal_type": goalType,
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Update failed: ${response.body}');
      return false;
    }
  }
}
