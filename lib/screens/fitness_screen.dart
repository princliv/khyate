import 'package:flutter/material.dart';
import 'package:khyate_b2b/widgets/membership_carousel.dart';
import '../widgets/fitness_sessions_grid.dart';
import '../widgets/todays_classes_component.dart';
import '../widgets/membership_card.dart';
import '../widgets/fitness_session_modal.dart';
import '../models/membership_card_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FitnessScreen extends StatelessWidget {
  final bool isDarkMode;

  const FitnessScreen({super.key, required this.isDarkMode});

  // Session descriptions map
  static const Map<String, String> sessionDescriptions = {
    "OUTRUSH": "OutRush is a high-intensity, heart-pumping cardio class that takes you through intervals of explosive movements like sprints, jumps, and quick footwork. Designed for all fitness levels, this workout will challenge your endurance and leave you feeling exhilarated. Our energizing playlist and motivating coaches will push you past your limits — helping you torch serious calories and improve cardiovascular fitness.\n\nOutRush is offered in 30 or 45-minute sessions.",
    "OUTBEAT": "OutBeat is a rhythmic cardio workout that blends dance-inspired movements with easy-to-follow routines. Powered by upbeat tracks, this session is all about moving to the rhythm, boosting your stamina, and having fun. Perfect for anyone who loves music and dance, this feel-good class will leave you sweating, smiling, and energized.\n\nOutBeat is offered in 45 or 60-minute sessions.",
    "OUTSTEP": "OutStep is a step-based aerobics class that brings a classic workout into a new era. You'll step up, down, and across the platform to the beat of motivating tunes. Designed for all fitness levels, this class enhances coordination, balance, and cardio fitness — all while toning your legs and glutes.\n\nOutStep is offered as a 30, 45, or 60-minute workout.",
    "OUTLIFT": "OutLift is a strength-training workout that targets every major muscle group using barbells, dumbbells, and bodyweight exercises. Our expert trainers will coach you through lifting techniques with the perfect mix of power and control. Get ready to build lean muscle, boost metabolism, and feel stronger every session.\n\nOutLift is offered in 45 or 60-minute sessions.",
    "OUTFIT": "OutFit is a functional fitness class designed to mimic real-life movements like pushing, pulling, and lifting. You'll improve strength, endurance, mobility, and coordination using a mix of bodyweight exercises and light equipment. Every workout is different — keeping your body challenged and your fitness balanced.\n\nOutFit is offered as a 45 or 60-minute workout.",
    "OUTMOVE": "OutMove is a bodyweight training session where no equipment is required — just your energy and drive. Combining exercises like lunges, squats, planks, and mobility drills, this class is perfect for toning muscles, improving flexibility, and burning calories. It's an accessible workout that can scale up or down for all fitness levels.\n\nOutMove is offered in 30 or 45-minute sessions.",
    "OUTCORE": "OutCore is a focused core-strengthening class that targets your abs, obliques, and lower back. Through a series of dynamic movements and stability exercises, you'll build a strong, stable core that supports better posture, improved balance, and enhanced overall strength. Perfect for all fitness levels, this class will help you develop the foundation for all your other workouts.\n\nOutCore is offered in 30 or 45-minute sessions.",
  };

  // Session image paths map (supports both network URLs and local assets)
  static const Map<String, String> sessionImages = {
    "OUTRUSH": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop&q=80", // High-intensity cardio/running
    "OUTBEAT": "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&h=400&fit=crop&q=80", // Dance fitness
    "OUTSTEP": "https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=800&h=400&fit=crop&q=80", // Step aerobics
    "OUTLIFT": "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&h=400&fit=crop&q=80", // Weightlifting/strength
    "OUTFIT": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=400&fit=crop&q=80", // Functional fitness
    "OUTMOVE": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80", // Bodyweight exercises
    "OUTCORE": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80", // Core training
  };

  @override
  Widget build(BuildContext context) {
    final sessions = [
      FitnessSession(
        label: "OUTSTEP",
        icon: Icons.directions_run,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutStep",
          sessionDescriptions["OUTSTEP"]!,
          isDarkMode,
          imagePath: sessionImages["OUTSTEP"],
        ),
      ),
      FitnessSession(
        label: "OUTCORE",
        icon: Icons.accessibility_new,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutCore",
          sessionDescriptions["OUTCORE"]!,
          isDarkMode,
          imagePath: sessionImages["OUTCORE"],
        ),
      ),
      FitnessSession(
        label: "OUTMOVE",
        icon: Icons.fitness_center,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutMove",
          sessionDescriptions["OUTMOVE"]!,
          isDarkMode,
          imagePath: sessionImages["OUTMOVE"],
        ),
      ),
      FitnessSession(
        label: "OUTFIT",
        icon: Icons.pan_tool,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutFit",
          sessionDescriptions["OUTFIT"]!,
          isDarkMode,
          imagePath: sessionImages["OUTFIT"],
        ),
      ),
      FitnessSession(
        label: "OUTLIFT",
        icon: Icons.self_improvement,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutLift",
          sessionDescriptions["OUTLIFT"]!,
          isDarkMode,
          imagePath: sessionImages["OUTLIFT"],
        ),
      ),
      FitnessSession(
        label: "OUTRUSH",
        icon: Icons.timeline,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutRush",
          sessionDescriptions["OUTRUSH"]!,
          isDarkMode,
          imagePath: sessionImages["OUTRUSH"],
        ),
      ),
      FitnessSession(
        label: "OUTBEAT",
        icon: Icons.favorite,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutBeat",
          sessionDescriptions["OUTBEAT"]!,
          isDarkMode,
          imagePath: sessionImages["OUTBEAT"],
        ),
      ),
    ];
Stream<List<MembershipCardData>> getMembershipsStream() {
  return FirebaseFirestore.instance
      .collection('membershipcards')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            return MembershipCardData.fromFirestore(doc.data(), doc.id);
          }).toList());
}

    final Color scaffoldBackground = isDarkMode 
    ? const Color(0xFF1A2332) 
    : const Color(0xFFFCEEE5);

    final Color headlineColor = isDarkMode ? const Color(0xFFC5A572) : const Color(0xFF1A2332);
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: 56),
            Text(
              "Discover the best in fitness & wellness",
              style: TextStyle(
                color: headlineColor,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            Text(
              "Your next workout, wellness class, or live session is just a click away",
              style: TextStyle(
                color: subTextColor,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search for anything",
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white54 : Colors.grey,
                          ),
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                  Container(
                    height: 48,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          // Location picker logic here
                        },
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Select location',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: MaterialButton(
                      color: Colors.red,
                      minWidth: 0,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, color: headlineColor),
                SizedBox(width: 8),
                Icon(Icons.android, color: headlineColor),
                SizedBox(width: 16),
                Text(
                  "Get the app today",
                  style: TextStyle(color: headlineColor),
                ),
              ],
            ),
            FitnessSessionsGrid(sessions: sessions,isDarkMode: isDarkMode),
            SizedBox(height: 28),
            TodaysClassesComponent(
              totalClasses: 27,
              dateString: "11-11-2025",
              hasPackage: false,
              onShowAllPressed: () {},
              onChoosePackagePressed: () {},
            ),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Top Membership',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: headlineColor,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {}, // Show all logic
                  child: Text(
                    "Show all (46) →",
                    style: TextStyle(
                        color: const Color(0xFFFF6767),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
  height: 430,
  child: StreamBuilder<List<MembershipCardData>>(
    stream: getMembershipsStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text("No memberships available"));
      }

      final memberships = snapshot.data!;

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: memberships.length,
        itemBuilder: (context, index) {
          return MembershipCard(
            data: memberships[index],
            onTap: () {},
          );
        },
      );
    },
  ),
),

            MembershipCarousel(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}