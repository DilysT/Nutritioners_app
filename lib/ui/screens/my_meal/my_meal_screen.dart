// my_meal_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';

class MyMealScreen extends StatelessWidget {
  const MyMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("My Meal Screen")),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
