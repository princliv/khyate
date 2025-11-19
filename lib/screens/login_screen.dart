import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';

  void signIn() async {
    try {
      await AuthService().signIn(emailController.text, passwordController.text);
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  void googleSignIn() async {
    try {
      await AuthService().signInWithGoogle();
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Login', style: TextStyle(color: Color(0xFF1A2332))),
        iconTheme: const IconThemeData(color: Color(0xFF1A2332)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            // Password
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5A572),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Login', style: TextStyle(color: Color(0xFF1A2332))),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: googleSignIn,
              icon: Image.asset('assets/google_logo.png', height: 24), // Add your own asset
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                elevation: 1,
                side: const BorderSide(color: Color(0xFFC5A572)),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OTPScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7D7A),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Sign in with Phone OTP'),
            ),
            const SizedBox(height: 8),
            Text(message),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            )
          ],
        ),
      ),
    );
  }
}
