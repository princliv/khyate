import 'package:Outbox/screens/home_screen.dart';
import 'package:Outbox/screens/onboarding_screen.dart';
import 'package:Outbox/screens/login_screen.dart';
import 'package:Outbox/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      
      setState(() {
        _isAuthenticated = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const HomeScreen();
    }

    // Show onboarding or login screen based on your flow
    // For now, showing login screen directly
    return const LoginScreen();
    
    // If you want to show onboarding first, use:
    // return const OnboardingScreen();
  }
}
