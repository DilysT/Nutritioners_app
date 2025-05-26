import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrition_app/ui/screens/authentication/login_screen.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'package:nutrition_app/ui/screens/settings/ai_assistant.dart'; // ✅ Đúng đường dẫn

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F1FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Color(0xFF007AFF), size: 22),
      ),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: showArrow ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSettingItem(
            icon: Icons.lock_outline,
            label: "Account",
            onTap: () => Navigator.pushNamed(context, '/settings/account'),
          ),
          _buildSettingItem(
            icon: Icons.person_outline,
            label: "Profile",
            onTap: () => Navigator.pushNamed(context, '/settings/profile'),
          ),
          _buildSettingItem(
            icon: Icons.layers_outlined,
            label: "Activity Level",
            onTap: () => Navigator.pushNamed(context, '/settings/activity-level'),
          ),

          // ✅ Thêm AI Assistant giữa Activity Level và Log out
          _buildSettingItem(
            icon: Icons.smart_toy_outlined,
            label: "AI Assistant",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
              );
            },
          ),

          _buildSettingItem(
            icon: Icons.logout,
            label: "Log out",
            onTap: () => _logout(context),
            showArrow: false,
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
