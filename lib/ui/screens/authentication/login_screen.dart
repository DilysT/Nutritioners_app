import 'package:flutter/material.dart';
import 'package:nutrition_app/ui/screens/authentication/forgot_password_screen.dart';
import 'package:nutrition_app/ui/screens/onboard/on_board_screen.dart';
import 'package:nutrition_app/ui/screens/dashboard/dashboard_screen.dart';
import 'package:nutrition_app/services/authenticate_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  void _goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnBoardScreen()),
    );
  }

  Future<void> _loginForm() async {
    final email = emailController.text;
    final password = passwordController.text;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final token = await AuthenticateApi.signin(email, password);
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!"), backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Login error: $e');
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
              const Text("Welcome Back", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Don't have an account?", style: TextStyle(fontSize: 15)),
                  TextButton(
                    onPressed: _goToSignup,
                    child: const Text("Sign up", style: TextStyle(color: Colors.blue, fontSize: 16)),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _forgotPassword, child: const Text("Forgot Password?")),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loginForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0072FD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
                    // Google Sign-In action (chưa tích hợp)
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
