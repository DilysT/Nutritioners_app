import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrition_app/models/user_model.dart';

class AuthenticateApi {

  static final String? baseUrl = dotenv.env['API_URL'];

  static Future<String?> signin(String email, String password) async {
    if (baseUrl == null) {
      print('API_URL not found in .env');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/users/login'),
        // adjust this to your actual endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Message: ${data['message']}');
        return data['token']; // return the token
      } else {
        print('Failed to signin: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String height,
    required String weight,
    required String weightGoal,
    required String birthday,
    required String activityLevel,
    required String gender,
    required String goalType,
    required String date,}) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/users/signup'), // Adjust this if needed
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'height': height,
          'weight': weight,
          'weight_goal': weightGoal,
          'birthday': birthday,
          'activity_level': activityLevel,
          'gender': gender,
          'goal_type': goalType,
          'date': date,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Message: ${data['message']}');
        return data['message'];
      } else {
        print('Failed to signup: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }
}
