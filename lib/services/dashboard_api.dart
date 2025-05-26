import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrition_app/services/token_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/dashboard_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class DashboardApi {
  static final ApiClient _client = ApiClient();

  static Future<DiaryData?> getDiaryByDate(String date) async {
    final response = await _client.get('api/auth/diaries/meals?date=$date');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['diary'] != null) {
        return DiaryData.fromJson(data['diary']);
      } else {
        print('No diary data found');
        return null;
      }
    } else {
      print('Failed to fetch diary: ${response.body}');
      return null;
    }
  }
}

