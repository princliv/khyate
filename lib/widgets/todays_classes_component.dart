import 'package:flutter/material.dart';

class TodaysClassesComponent extends StatelessWidget {
  final int totalClasses;
  final String dateString;
  final bool hasPackage;
  final VoidCallback onShowAllPressed;
  final VoidCallback onChoosePackagePressed;

  const TodaysClassesComponent({
    super.key,
    required this.totalClasses,
    required this.dateString,
    required this.hasPackage,
    required this.onShowAllPressed,
    required this.onChoosePackagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2331),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Classes",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF67616C),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              TextButton(
                onPressed: onShowAllPressed,
                child: Text(
                  "Show all ($totalClasses) →",
                  style: TextStyle(
                    color: Color(0xFFFF6767),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            hasPackage ? "" : "No active package selected",
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onChoosePackagePressed,
              child: Text(
                "Choose Package",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "$dateString Schedule",
                    style: TextStyle(
                      color: Color(0xFF53A7DB),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  child: Text(
                    "No classes scheduled for this day.",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
