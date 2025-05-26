import 'package:flutter/material.dart';
import 'package:nutrition_app/models/user_data.dart';
import 'package:nutrition_app/services/authenticate_api.dart';
import 'package:nutrition_app/ui/screens/authentication/login_screen.dart';
import 'package:nutrition_app/ui/screens/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isChecked = false;

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _signupForm() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final userData = Provider.of<UserData>(context, listen: false);

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept our policy to continue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email and password cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate required fields
    final missingFields = <String>[];
    if (userData.name == null || userData.name!.isEmpty) missingFields.add("Name");
    if (userData.gender == null) missingFields.add("Gender");
    if (userData.birthday == null) missingFields.add("Birthday");
    if (userData.height == null) missingFields.add("Height");
    if (userData.weight == null) missingFields.add("Weight");
    if (userData.weight_goal == null) missingFields.add("Weight Goal");
    if (userData.goal_type == null) missingFields.add("Goal Type");
    if (userData.activity_level == null) missingFields.add("Activity Level");

    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Missing fields: ${missingFields.join(', ')}"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await AuthenticateApi.signup(
        email: email,
        password: password,
        activityLevel: userData.activity_level!,
        birthday: userData.birthday!,
        date: DateTime.now().toIso8601String().split('T')[0],
        gender: userData.gender!,
        goalType: userData.goal_type!,
        height: userData.height!,
        name: userData.name!,
        weight: userData.weight!,
        weightGoal: userData.weight_goal!,
      );

      if (response != null) {
        final token = await AuthenticateApi.signin(email, password);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', token!);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signup failed. Please check your information."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Signup error: $e');
    }
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
              const Text("Create Account", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Already have an account?", style: TextStyle(fontSize: 15)),
                  TextButton(
                    onPressed: _goToLogin,
                    child: const Text("Login", style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
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
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text("I agree to Terms of Service and Privacy Policy"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signupForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0072FD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.grey, thickness: 1.5)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                  ),
                  const Expanded(child: Divider(color: Colors.grey, thickness: 1.5)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Google Sign-In
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  icon: Image.asset(
                    'lib/ui/assets/google_icons.webp',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
