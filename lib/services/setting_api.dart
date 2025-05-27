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

  static Future<bool> updateUserInformation(Map<String, dynamic> updatedFields) async {
    final response = await _client.put(
      'api/auth/users',
      body: updatedFields,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Update failed: ${response.body}');
      return false;
    }
  }

}
