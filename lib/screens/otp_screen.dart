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
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => message = 'Please enter your phone number or email');
      return;
    }

    setState(() {
      message = 'Sending OTP...';
    });

    try {
      await AuthService().generateOTP(phone);
      setState(() {
        verificationId = phone; // Use phone/email as identifier
        message = "OTP sent to $phone";
      });
    } catch (e) {
      setState(() {
        String errorMsg = e.toString();
        errorMsg = errorMsg.replaceAll('Exception: ', '');
        message = errorMsg;
      });
    }
  }

  void verifyOTP() async {
    if (verificationId == null) {
      setState(() => message = 'Please send OTP first');
      return;
    }

    if (otpController.text.trim().isEmpty) {
      setState(() => message = 'Please enter the OTP code');
      return;
    }

    setState(() {
      message = 'Verifying OTP...';
    });

    try {
      final result = await AuthService().verifyOTP(
        emailOrPhone: verificationId!,
        otp: otpController.text.trim(),
      );
      if (result != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const HomeScreen()), 
          (_) => false
        );
      } else {
        setState(() => message = 'OTP verification failed. Please try again.');
      }
    } catch (e) {
      setState(() {
        String errorMsg = e.toString();
        errorMsg = errorMsg.replaceAll('Exception: ', '');
        message = errorMsg;
      });
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
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email or Phone",
                  hintText: "Enter your email or phone number",
                ),
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
