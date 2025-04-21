import 'package:flutter/material.dart';
import '../ui/screens/dashboard/dashboard_screen.dart';
import '../ui/screens/my_meal/my_meal_screen.dart';
import '../ui/screens/settings/settings_screen.dart';

class AppRoutes {
  static final routes = {
    '/': (context) => const DashboardScreen(),
    '/my-meal': (context) => const MyMealScreen(),
    '/settings': (context) => const SettingsScreen(),
  };
}
