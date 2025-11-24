import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khyate_b2b/models/cart_model.dart';
import 'package:khyate_b2b/providers/cart_provider.dart';
import 'package:khyate_b2b/services/purchase_status_service.dart';
import 'package:provider/provider.dart';
import '../widgets/fitness_sessions_grid.dart';

class WellnessScreen extends StatelessWidget {
  final bool isDarkMode;

  const WellnessScreen({super.key, required this.isDarkMode});

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
      FitnessSession(label: "OUTCALM", icon: Icons.self_improvement, onTap: () {}),
      FitnessSession(label: "OUTROOT", icon: Icons.yard, onTap: () {}),
      FitnessSession(label: "OUTCREATE", icon: Icons.brush, onTap: () {}),
      FitnessSession(label: "OUTFLOW", icon: Icons.waterfall_chart, onTap: () {}),
      FitnessSession(label: "OUTGLOW", icon: Icons.wb_incandescent, onTap: () {}),
      FitnessSession(label: "OUTSOUND", icon: Icons.music_note, onTap: () {}),
      FitnessSession(label: "OUTDREAM", icon: Icons.nights_stay, onTap: () {}),
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
                  Text("🕒 ${d['duration']}", style: TextStyle(color: subTextColor)),
                  Text("👤 ${d['mentor']}", style: TextStyle(color: subTextColor)),
                  Text("₹ ${d['price']}", style: TextStyle(color: headlineColor)),
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
      return Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text("Purchased", style: TextStyle(color: Colors.white)),
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
