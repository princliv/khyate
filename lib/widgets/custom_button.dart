import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgColor;
  final Color fgColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.bgColor = const Color(0xFFC5A572),
    this.fgColor = const Color(0xFF1A2332),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0.5,
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
