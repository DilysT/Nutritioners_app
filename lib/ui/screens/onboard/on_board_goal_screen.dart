import 'package:flutter/material.dart';
import 'package:nutrition_app/models/user_data.dart';
import 'package:nutrition_app/ui/screens/onboard/on_board_activity_level_screen.dart';
import 'package:provider/provider.dart';

class OnBoardGoalScreen extends StatefulWidget {
  const OnBoardGoalScreen({super.key});

  @override
  State<OnBoardGoalScreen> createState() => _OnBoardGoalScreenState();
}

class _OnBoardGoalScreenState extends State<OnBoardGoalScreen> {
  String? selectedGoal;

  void _selectGoal(String goal, BuildContext context) {
    setState(() {
      selectedGoal = goal;
    });

    // ✅ Cập nhật dữ liệu người dùng SAU khi đã có userData
    final userData = Provider.of<UserData>(context, listen: false);
    if (goal == 'Gain weight') {
      userData.goal_type = 'weight gain';
    } else if (goal == 'Lose weight') {
      userData.goal_type = 'weight loss';
    }

    // ✅ Tiếp tục navigation sau delay
    Future.delayed(const Duration(milliseconds: 30), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnBoardActivityLevelScreen()),
      );
    });
  }

  Widget _buildGoalButton(String text, BuildContext context) {
    final isSelected = selectedGoal == text;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _selectGoal(text, context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF0072FD) : Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.black,
          ),
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
              width: 70,
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
                "What is your goal?",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Set the health objective you’re aiming to achieve.",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 30),
              _buildGoalButton("Gain weight", context),
              const SizedBox(height: 20),
              _buildGoalButton("Lose weight", context),
            ],
          ),
        ),
      ),
    );
  }
}
