import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/services/review_service.dart';
import 'package:Outbox/widgets/review_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:khyate_b2b/models/cart_model.dart';
// import 'package:khyate_b2b/providers/cart_provider.dart';
// import 'package:khyate_b2b/services/purchase_status_service.dart';
// import 'package:khyate_b2b/widgets/review_widget.dart';
import 'package:provider/provider.dart';
import '../widgets/fitness_sessions_grid.dart';
import '../widgets/fitness_session_modal.dart';
import '../widgets/wellness_modal.dart';

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
    // Brand Colors - Wellness (Brown/Gold: #AD8654)
    final Color scaffoldBackground =
        isDarkMode ? const Color(0xFF353535) : const Color(0xFFFCEEE5);

    final Color headlineColor =
        isDarkMode ? const Color(0xFFAD8654) : const Color(0xFF353535);

    final Color subTextColor = const Color(0xFF99928D);
    final Color accentColor = const Color(0xFFAD8654); // Brown/Gold for Wellness
    
    // Brand Fonts
    final TextStyle headlineStyle = GoogleFonts.montserrat(
      fontSize: 38,
      fontWeight: FontWeight.bold,
      color: headlineColor,
    );
    final TextStyle bodyStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: subTextColor,
    );

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
              style: headlineStyle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            Text(
              "Find peace, healing, creativity, and flow — curated for you.",
              style: bodyStyle,
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
    style: GoogleFonts.montserrat(
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
        final data = d.data() as Map<String, dynamic>;
        final String imageUrl = (data['imageUrl'] as String?) ?? '';

        return InkWell(
          onTap: () {
            WellnessModal.show(context, data, d.id, isDarkMode);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
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
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/default_thumbnail.webp',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),

              const SizedBox(height: 12),

              // TITLE
              Text(
                data['title'],
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: headlineColor,
                ),
              ),

              const SizedBox(height: 4),

              // SUBTITLE
              Text(
                data['subtitle'],
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: subTextColor,
                ),
              ),

              const SizedBox(height: 12),

              // DETAILS SECTION - Better organized layout
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // First Row: Duration and Date
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: accentColor,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data['duration'] ?? 'N/A',
                                  style: GoogleFonts.inter(
                                    color: subTextColor,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: accentColor,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data['date'] ?? 'No Date',
                                  style: GoogleFonts.inter(
                                    color: subTextColor,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    // Second Row: Trainer and Price
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 18,
                                color: accentColor,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data['mentor'] ?? 'N/A',
                                  style: GoogleFonts.inter(
                                    color: subTextColor,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? accentColor.withOpacity(0.2) 
                                : accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "AED ${data['price'] ?? '0'}",
                            style: GoogleFonts.montserrat(
                              color: headlineColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // DESCRIPTION - Limited to one line with ellipsis
              Text(
                data['description'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: subTextColor,
                ),
              ),
              SizedBox(height: 12),

              // REVIEW AVERAGE
              StreamBuilder<double>(
                stream: ReviewService.avgRating(d.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final rating = snapshot.data!;
                    return Row(
                      children: [
                        Icon(
                          rating > 0 ? Icons.star : Icons.star_border,
                          color: rating > 0 ? Colors.amber : subTextColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating > 0
                              ? "Review: ${rating.toStringAsFixed(1)}"
                              : "0 review",
                          style: GoogleFonts.inter(
                            color: subTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Icon(Icons.star_border, color: subTextColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "0 review",
                        style: GoogleFonts.inter(
                          color: subTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                },
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
      child: Text(
        "Purchased",
        style: GoogleFonts.inter(color: Colors.white),
      ),
    ),
    const SizedBox(height: 10),
    ReviewWidget(cardId: d.id),
  ],
);

    }

    final cartItems = Provider.of<CartProvider>(context).items;
    final isInCart = cartItems.any((item) => item.id == d.id);

    if (isInCart) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Added",
              style: GoogleFonts.inter(
                color: Colors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: TextButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).removeItem(d.id);
              },
              child: Text(
                "Remove",
                style: GoogleFonts.inter(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Standardized "Add to Cart" button styling
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<CartProvider>(context, listen: false).addItem(
            CartItem(
              id: d.id,
              title: data['title'],
              imageUrl: imageUrl.isNotEmpty
                  ? imageUrl
                  : 'assets/default_thumbnail.webp',
              price: int.parse(data['price']),
              type: "wellness",
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Add to Cart",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  },
)


            ],
          ),
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
