import 'package:flutter/material.dart';
import '../../../services/setting_api.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both passwords.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await ApiService.getUserInformation();
      final user = data.user;
      final goal = data.goal;

      final success = await ApiService.updateUserInformation({
        "name": user.name,
        "email": user.email,
        "password": currentPassword,
        "newPassword": newPassword,
        "weight": double.tryParse(user.weight) ?? 0,
        "height": double.tryParse(user.height) ?? 0,
        "activity_level": user.activityLevel,
        "gender": user.gender,
        "birthday": user.birthday,
        "weight_goal": goal.weightGoal,
        "goal_type": goal.goalType,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Password changed successfully!' : 'Failed to change password.'),
      ));

      if (success) Navigator.pop(context);

    } catch (e) {
      debugPrint('Error changing password: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF007AFF)),
        title: const Text("Change Password", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Password", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
