import 'package:flutter/material.dart';
import 'package:nutrition_app/ui/screens/onboard/on_board_goal_screen.dart';

class CheckYourEmailScreen extends StatefulWidget {
  const CheckYourEmailScreen({super.key});

  @override
  State<CheckYourEmailScreen> createState() => _CheckYourEmailScreen();
}

class _CheckYourEmailScreen extends State<CheckYourEmailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Check Your Email",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "We have sent an email with password reset information to n****e@e***e.com.",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 30), // space before input fields
              const Text(
                "Didn’t receive the email? Check spam or promotion folder "
                "or tap resend email",
                style: TextStyle(fontSize: 15),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnBoardGoalScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0072FD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Resend email',
              style: TextStyle(
                fontWeight: FontWeight.w600, // semi-bold text
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
