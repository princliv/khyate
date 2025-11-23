import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khyate_b2b/models/membership_model.dart';


class MembershipCarousel extends StatelessWidget {
  const MembershipCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('memberships').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snap.data!.docs.map((doc) {
          return MembershipCarouselData.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
        return _buildCarousel(items);
      },
    );
  }

  Widget _buildCarousel(List<MembershipCarouselData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Text(
          "Find Your New Latest Packages",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0)),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 410,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildCard(items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(MembershipCarouselData card) {
    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              card.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(16)),
                      child: Text(card.tag),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Color(0xFFCEF9EF), borderRadius: BorderRadius.circular(12)),
                      child: Text(card.classes),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Text(card.type, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black87)),

                SizedBox(height: 4),

                Row(
                  children: [
                    Text(card.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(card.price, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),

                SizedBox(height: 12),

                for (var f in card.features)
                  Row(
                    children: [
                      Icon(Icons.check, color: Color(0xFF16AE8E), size: 18),
                      SizedBox(width: 5),
                      Text(f),
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
