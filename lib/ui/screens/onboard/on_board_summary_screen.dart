import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/models/user_data.dart';
import 'package:nutrition_app/ui/screens/authentication/signup_screen.dart';

class OnBoardSummaryScreen extends StatefulWidget {
  const OnBoardSummaryScreen({super.key});

  @override
  State<OnBoardSummaryScreen> createState() => _OnBoardSummaryScreenState();
}

class _OnBoardSummaryScreenState extends State<OnBoardSummaryScreen> {
  double? adjustedTDEE;
  DateTime? goalDate;

  @override
  void initState() {
    super.initState();
    _calculateCalorieAndGoalDate();
  }

  void _calculateCalorieAndGoalDate() {
    final user = Provider.of<UserData>(context, listen: false);

    final double weight = double.parse(user.weight!);
    final double height = double.parse(user.height!);
    final double weightGoal = double.parse(user.weight_goal!);
    final String gender = user.gender!;
    final String activityLevel = user.activity_level!;
    final DateTime birthday = DateTime.parse(user.birthday!);
    final String goalType = user.goal_type!;

    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }

    double BMR;
    if (gender.toLowerCase() == 'male') {
      BMR = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      BMR = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    double activityFactor;
    switch (activityLevel.toLowerCase()) {
      case 'not very active':
        activityFactor = 1.375;
        break;
      case 'moderately active':
        activityFactor = 1.55;
        break;
      case 'active':
        activityFactor = 1.725;
        break;
      case 'very active':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2;
    }

    final double tdee = BMR * activityFactor;

    if (goalType == 'weight loss') {
      adjustedTDEE = double.parse((tdee - 500).toStringAsFixed(2));
    } else if (goalType == 'weight gain') {
      // hoặc sửa này nếu BE là "Gain weight"
      adjustedTDEE = double.parse((tdee + 500).toStringAsFixed(2));
    } else {
      adjustedTDEE = double.parse(tdee.toStringAsFixed(2));
    }


    final double diff = (weight - weightGoal).abs();
    final int days = (diff / 0.5 * 7).round();
    goalDate = DateTime.now().add(Duration(days: days));

    // 🧾 DEBUG LOG
    print('===== TDEE CALCULATION LOG =====');
    print('Gender: $gender');
    print('Weight: $weight');
    print('Height: $height');
    print('Birthday: $birthday');
    print('Age: $age');
    print('Activity Level: $activityLevel');
    print('Activity Factor: $activityFactor');
    print('BMR: ${BMR.toStringAsFixed(2)}');
    print('Raw TDEE: ${tdee.toStringAsFixed(2)}');
    print('Adjusted TDEE ($goalType): ${adjustedTDEE?.toStringAsFixed(2)}');
    print('Weight Goal: $weightGoal');
    print('Days to goal: $days');
    print('Goal date: $goalDate');
    print('=================================');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String displayDate = goalDate != null ? DateFormat('MMMM dd, yyyy').format(goalDate!) : '...';
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/ui/assets/back_ground_1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Congratulation 🎉",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Your daily net calorie goal is:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            adjustedTDEE != null ? adjustedTDEE!.toStringAsFixed(0) : '...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You can reach your goal by $displayDate',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
