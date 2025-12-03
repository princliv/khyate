import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/widgets/review_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:khyate_b2b/models/cart_model.dart';
// import 'package:khyate_b2b/providers/cart_provider.dart';
// import 'package:khyate_b2b/services/purchase_status_service.dart';
// import 'package:khyate_b2b/widgets/review_widget.dart';
import 'package:provider/provider.dart';
import '../widgets/fitness_sessions_grid.dart';
import '../widgets/fitness_session_modal.dart';

class WellnessScreen extends StatelessWidget {
  final bool isDarkMode;

  const WellnessScreen({super.key, required this.isDarkMode});

  // Session descriptions map
  static const Map<String, String> sessionDescriptions = {
    "OUTCALM": "OutCalm is a deeply relaxing meditation and sound bath session designed to soothe your mind and body. Gentle breathwork, calming soundscapes, and subtle aromatherapy help you unwind, reduce stress, and leave feeling refreshed.\n\nOutCalm is perfect for all levels and offered in 30 or 45-minute sessions.",
    "OUTROOT": "OutRoot is a grounding, nature-inspired session that blends gentle breathwork and slow movement to help you reconnect with the present. Held outdoors whenever possible, this practice uses simple grounding exercises and light stretches to restore balance and inner calm.\n\nOutRoot is suitable for all levels and offered in 30 or 45 minute sessions.",
    "OUTCREATE": "OutCreate is a playful, art-based workshop designed to spark creativity and ease the mind. Participants draw, paint, or craft as they move gently and breathe mindfully — releasing tension and self-judgment.\n\nOutCreate is perfect for all skill levels and offered in 45 minute sessions.",
    "OUTFLOW": "OutFlow is a free-form movement session that invites you to dance, stretch, and flow without judgment. Inspired by intuitive movement and set to uplifting music, it's all about releasing energy and finding joy in your body.\n\nOutFlow is suitable for everyone and offered in 30 or 45 minute sessions.",
    "OUTGLOW": "OutGlow is a gentle yoga session illuminated by candlelight, encouraging relaxation and self-care. Soft stretches, deep breaths, and calming poses help you release tension and leave with a warm inner glow.\n\nOutGlow is open to all levels and offered in 45 minute sessions.",
    "OUTSOUND": "OutSound is an immersive sound-healing session using gongs, singing bowls, and chimes to realign your energy. Let the vibrations wash over you as you sink into deep relaxation.\n\nOutSound is perfect for all levels and offered in 45 minute sessions.",
    "OUTDREAM": "OutDream is a guided visualization and relaxation practice that taps into your imagination. Gentle cues help you drift into a dream-like state, melting away stress and leaving you inspired and at ease.\n\nOutDream is suitable for all levels and offered in 30 minute sessions.",
  };

  // Session image paths map (supports both network URLs and local assets)
  static const Map<String, String> sessionImages = {
    "OUTCALM": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80", // Meditation
    "OUTROOT": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=400&fit=crop&q=80", // Nature/grounding
    "OUTCREATE": "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800&h=400&fit=crop&q=80", // Art/creativity
    "OUTFLOW": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80", // Movement/dance
    "OUTGLOW": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&h=400&fit=crop&q=80", // Yoga/candlelight
    "OUTSOUND": "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop&q=80", // Sound healing
    "OUTDREAM": "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop&q=80", // Dream/visualization
  };

  @override
  Widget build(BuildContext context) {
    final Color scaffoldBackground =
        isDarkMode ? const Color(0xFF1A2332) : const Color(0xFFFCEEE5);

    final Color headlineColor =
        isDarkMode ? const Color(0xFFC5A572) : const Color(0xFF1A2332);

    final Color subTextColor =
        isDarkMode ? Colors.white70 : Colors.black54;

    /// --------------------------------------------------------
    /// WELLNESS SESSIONS (icons only top section)
    /// --------------------------------------------------------
    final sessions = [
      FitnessSession(
        label: "OUTCALM",
        icon: Icons.self_improvement,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutCalm",
          sessionDescriptions["OUTCALM"]!,
          isDarkMode,
          imagePath: sessionImages["OUTCALM"],
        ),
      ),
      FitnessSession(
        label: "OUTROOT",
        icon: Icons.yard,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutRoot",
          sessionDescriptions["OUTROOT"]!,
          isDarkMode,
          imagePath: sessionImages["OUTROOT"],
        ),
      ),
      FitnessSession(
        label: "OUTCREATE",
        icon: Icons.brush,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutCreate",
          sessionDescriptions["OUTCREATE"]!,
          isDarkMode,
          imagePath: sessionImages["OUTCREATE"],
        ),
      ),
      FitnessSession(
        label: "OUTFLOW",
        icon: Icons.waterfall_chart,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutFlow",
          sessionDescriptions["OUTFLOW"]!,
          isDarkMode,
          imagePath: sessionImages["OUTFLOW"],
        ),
      ),
      FitnessSession(
        label: "OUTGLOW",
        icon: Icons.wb_incandescent,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutGlow",
          sessionDescriptions["OUTGLOW"]!,
          isDarkMode,
          imagePath: sessionImages["OUTGLOW"],
        ),
      ),
      FitnessSession(
        label: "OUTSOUND",
        icon: Icons.music_note,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutSound",
          sessionDescriptions["OUTSOUND"]!,
          isDarkMode,
          imagePath: sessionImages["OUTSOUND"],
        ),
      ),
      FitnessSession(
        label: "OUTDREAM",
        icon: Icons.nights_stay,
        onTap: () => FitnessSessionModal.show(
          context,
          "OutDream",
          sessionDescriptions["OUTDREAM"]!,
          isDarkMode,
          imagePath: sessionImages["OUTDREAM"],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 56),

            /// TITLE
            Text(
              "Discover the best in wellness",
              style: TextStyle(
                color: headlineColor,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            Text(
              "Find peace, healing, creativity, and flow — curated for you.",
              style: TextStyle(
                color: subTextColor,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            /// ----------------------------------------
            /// ICON GRID ONLY (NO SEARCH / NO LOCATION)
            /// ----------------------------------------
            FitnessSessionsGrid(
              sessions: sessions,
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 32),

            /// Placeholder section for future cards
            const SizedBox(height: 32),

Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Wellness Programs",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: headlineColor,
    ),
  ),
),

const SizedBox(height: 20),

StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection("wellnesscards").snapshots(),
  builder: (context, snap) {
    if (!snap.hasData) {
      return Center(child: CircularProgressIndicator());
    }

    final docs = snap.data!.docs;

    return Column(
      children: docs.map((d) {
        return Container(
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black26 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black12,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  d['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 12),

              // TITLE
              Text(
                d['title'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: headlineColor,
                ),
              ),

              const SizedBox(height: 4),

              // SUBTITLE
              Text(
                d['subtitle'],
                style: TextStyle(
                  fontSize: 16,
                  color: subTextColor,
                ),
              ),

              const SizedBox(height: 10),

              // DETAILS ROW
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text("🕒 ${d['duration']}",
        style: TextStyle(color: subTextColor)
    ),

    Text("📅 ${d.data().toString().contains('date') ? d['date'] : 'No Date'}",
  style: TextStyle(color: subTextColor),
),


    Text("👤 ${d['mentor']}",
        style: TextStyle(color: subTextColor)
    ),

    Text("AED ${d['price']}",
        style: TextStyle(color: headlineColor)
    ),
  ],
),




              const SizedBox(height: 10),

              // DESCRIPTION
              Text(
                d['description'],
                style: TextStyle(
                  fontSize: 15,
                  color: subTextColor,
                ),
              ),
              SizedBox(height: 12),

FutureBuilder<bool>(
  future: PurchaseStatusService.isPurchased(d.id),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    final purchased = snapshot.data!;

    if (purchased) {
      return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text("Purchased", style: TextStyle(color: Colors.white)),
    ),
    const SizedBox(height: 10),
    ReviewWidget(cardId: d.id),
  ],
);

    }

    return ElevatedButton(
      onPressed: () {
        Provider.of<CartProvider>(context, listen: false).addItem(
          CartItem(
            id: d.id,
            title: d['title'],
            imageUrl: d['imageUrl'],
            price: int.parse(d['price']),
            type: "wellness",
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text("Add to Cart"),
    );
  },
)


            ],
          ),
        );
      }).toList(),
    );
  },
),


            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
