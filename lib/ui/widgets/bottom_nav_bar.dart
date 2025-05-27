import 'package:flutter/material.dart';
import 'package:nutrition_app/ui/screens/dashboard/dashboard_screen.dart';
import 'package:nutrition_app/ui/screens/my_meal/my_meal_screen.dart';
import 'package:nutrition_app/ui/screens/settings/settings_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(_createRoute('/'));
        break;
      case 1:
        Navigator.of(context).pushReplacement(_createRoute('/my-meal'));
        break;
      case 2:
        Navigator.of(context).pushReplacement(_createRoute('/settings'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.blue,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'My Meal'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  PageRouteBuilder _createRoute(String routeName) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _getPage(routeName); // Hàm này trả về widget tương ứng với route
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Widget _getPage(String routeName) {
    switch (routeName) {
      case '/':
        return const DashboardScreen(); // Đảm bảo rằng DashboardScreen được import chính xác
      case '/my-meal':
        return const MyMealScreen(); // Đảm bảo rằng MyMealScreen được import chính xác
      case '/settings':
        return const SettingsScreen(); // Đảm bảo rằng SettingsScreen được import chính xác
      default:
        return const Scaffold(body: Center(child: Text('Unknown route')));
    }
  }
}
