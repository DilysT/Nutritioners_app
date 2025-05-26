import 'package:flutter/material.dart';
import 'package:nutrition_app/models/user_data.dart';
import 'package:nutrition_app/ui/screens/onboard/on_board_complete_stage_screen.dart';
import 'package:provider/provider.dart';

class OnBoardActivityLevelScreen extends StatefulWidget {
  const OnBoardActivityLevelScreen({super.key});

  @override
  State<OnBoardActivityLevelScreen> createState() => _OnBoardActivityLevelScreenState();
}

class _OnBoardActivityLevelScreenState extends State<OnBoardActivityLevelScreen> {
  String? selectedActivity;

  void _selectActivity(String activity, BuildContext context) {
    setState(() {
      selectedActivity = activity;
    });

    // Cập nhật dữ liệu cho UserData
    final userData = Provider.of<UserData>(context, listen: false);
    userData.activity_level = activity;

    // Chờ 300ms để hiển thị hiệu ứng chọn rồi chuyển trang
    Future.delayed(const Duration(milliseconds: 30), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnBoardCompleteStage()),
      );
    });
  }

  Widget _buildActivityButton({
    required String title,
    required String description,
    required String activity,
    required BuildContext context,
  }) {
    final bool isSelected = selectedActivity == activity;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _selectActivity(activity, context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF0072FD) : Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: isSelected ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 140,
              height: 5,
              color: Colors.blue,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What is your activity level?",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Tell us how active you are in your daily routine.",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 30),
              _buildActivityButton(
                title: 'Not very active',
                description: 'You spend most of your day sitting or doing minimal physical activity.',
                activity: 'not very active',
                context: context,
              ),
              const SizedBox(height: 20),
              _buildActivityButton(
                title: 'Moderately active',
                description: 'You engage in light physical activity, like walking or occasional exercise.',
                activity: 'moderately active',
                context: context,
              ),
              const SizedBox(height: 20),
              _buildActivityButton(
                title: 'Active',
                description: 'You are regularly active, exercising several times a week and moving often.',
                activity: 'active',
                context: context,
              ),
              const SizedBox(height: 20),
              _buildActivityButton(
                title: 'Very active',
                description: 'You have a highly active lifestyle, engaging in intense exercise or physical labor daily.',
                activity: 'very active',
                context: context,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
