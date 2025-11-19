import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String? verificationId;
  String message = '';

  void sendCode() async {
    final phone = phoneController.text;
    await AuthService().verifyPhoneNumber(
      phone: phone,
      codeSent: (id) {
        setState(() => verificationId = id);
        message = "OTP sent to $phone";
      },
      onSuccess: (user) {
        Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
      },
      onError: (msg) => setState(() => message = msg),
    );
  }

  void verifyOTP() async {
    if (verificationId == null) return;
    try {
      await AuthService().signInWithOTP(verificationId!, otpController.text);
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF8),
      appBar: AppBar(
        title: const Text('Phone OTP Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2332)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (verificationId == null)
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone (+123456789)"),
              ),
            if (verificationId != null) ...[
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: "Enter OTP"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A572),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text("Verify OTP"),
              )
            ],
            if (verificationId == null)
              ElevatedButton(
                onPressed: sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A572),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text("Send OTP"),
              ),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
      ),
    );
  }
}
