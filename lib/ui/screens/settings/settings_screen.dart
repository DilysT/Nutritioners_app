// settings_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("Settings Screen")),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
