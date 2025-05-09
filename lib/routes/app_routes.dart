import 'package:flutter/material.dart';
import '../ui/screens/dashboard/dashboard_screen.dart';
import '../ui/screens/my_meal/my_meal_screen.dart';
import '../ui/screens/settings/settings_screen.dart';
import '../ui/screens/settings/account_screen.dart'; // 👈 Thêm dòng này
import '../ui/screens/settings/profile_screen.dart';
import '../ui/screens/settings/activity_level_screen.dart';
class AppRoutes {
  static const String dashboard = '/';
  static const String myMeal = '/my-meal';
  static const String settings = '/settings';
  static const String account = '/settings/account';
  static const String profile = '/settings/profile';              // ✅ mới
  static const String activity = '/settings/activity-level';

  static final routes = {
    dashboard: (context) => const DashboardScreen(),
    myMeal: (context) => const MyMealScreen(),
    settings: (context) => const SettingsScreen(),
    account: (context) => const AccountScreen(),
    profile: (context) => const ProfileScreen(),                  // ✅ mới
    activity: (context) => const ActivityLevelScreen(),
  };
}

