import 'package:flutter/material.dart';
import 'package:nutrition_app/models/user_data.dart';
import 'package:nutrition_app/ui/screens/onboard/on_board_goal_screen.dart';
import 'package:provider/provider.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreen();
}

class _OnBoardScreen extends State<OnBoardScreen> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();

  bool isFilled = false;

  @override
  void initState() {
    super.initState();
    firstnameController.addListener(_checkFields);
    lastnameController.addListener(_checkFields);
  }

  void _checkFields() {
    final filled = firstnameController.text.isNotEmpty && lastnameController.text.isNotEmpty;
    if (filled != isFilled) {
      setState(() {
        isFilled = filled;
      });
    }
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What is your name?",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Tell us your name to personalize your experience.",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: firstnameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: lastnameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isFilled
                ? () {
              final userData = Provider.of<UserData>(context, listen: false);
              userData.name =
              '${lastnameController.text} ${firstnameController.text}';
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OnBoardGoalScreen()),
              );
            }
                : null, // 👈 disable nếu chưa điền đủ
            style: ElevatedButton.styleFrom(
              backgroundColor: isFilled ? const Color(0xFF0072FD) : Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
