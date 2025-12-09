import 'package:Outbox/screens/home_screen.dart';
import 'package:Outbox/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User not logged in
        if (!snapshot.hasData) {
          return OnboardingScreen();
        }

        // User logged in
        return const HomeScreen();
      },
    );
  }
}
