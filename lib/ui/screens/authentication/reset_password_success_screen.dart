import 'package:flutter/material.dart';
import 'package:nutrition_app/ui/screens/authentication/check_your_email_screen.dart';
import 'package:nutrition_app/ui/screens/onboard/on_board_goal_screen.dart';

class ResetPasswordSuccessScreen extends StatefulWidget {
  const ResetPasswordSuccessScreen({super.key});

  @override
  State<ResetPasswordSuccessScreen> createState() => _ResetPasswordSuccessScreen();
}

class _ResetPasswordSuccessScreen extends State<ResetPasswordSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


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
                  builder: (context) => const CheckYourEmailScreen(),
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
              'Login',
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
