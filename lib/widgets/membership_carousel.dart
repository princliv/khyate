import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khyate_b2b/models/cart_model.dart';
import 'package:khyate_b2b/models/membership_model.dart';
import 'package:khyate_b2b/providers/cart_provider.dart';
import 'package:khyate_b2b/services/purchase_status_service.dart';
import 'package:khyate_b2b/widgets/review_widget.dart';
import 'package:provider/provider.dart';

class MembershipCarousel extends StatelessWidget {
  final String searchQuery;
  final String? selectedTrainer;
  final bool filterFutureDate;

  const MembershipCarousel({
    super.key,
    this.searchQuery = '',
    this.selectedTrainer,
    this.filterFutureDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('memberships').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No memberships found"));
        }

        // Map Firestore docs to MembershipCarouselData
        final items = snapshot.data!.docs.map((doc) {
          return MembershipCarouselData.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        // Apply filters
        final filteredItems = items.where((card) {
          final matchesName =
              searchQuery.isEmpty || card.title.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesTrainer =
              selectedTrainer == null || card.mentor == selectedTrainer;
          final matchesDate = !filterFutureDate ||
              (card.date.isNotEmpty &&
                  DateTime.tryParse(card.date)?.isAfter(DateTime.now()) == true);
          return matchesName && matchesTrainer && matchesDate;
        }).toList();

        return _buildCarousel(filteredItems, context);
      },
    );
  }

  Widget _buildCarousel(List<MembershipCarouselData> items, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          "Find Your New Latest Packages",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => _buildCard(item, context),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(MembershipCarouselData card, BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 420,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              /// IMAGE
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  card.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              /// DETAILS
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  /// TAG + CLASSES
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(card.tag),
                      ),
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCEF9EF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(card.classes),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    card.type,
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "AED ${card.price}",
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// TRAINER NAME
                  if (card.mentor.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.person,
                            color: Colors.blueGrey, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "Trainer: ${card.mentor}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  /// DATE
                  if (card.date.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.pinkAccent),
                        const SizedBox(width: 6),
                        Text(
                          "Date: ${card.date}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  /// LOCATION
if (card.location.isNotEmpty) ...[
  Row(
    children: [
      const Icon(Icons.location_on,
          size: 16, color: Colors.redAccent),
      const SizedBox(width: 6),
      Text(
        "Location: ${card.location}",
        style: const TextStyle(
            fontSize: 14, color: Colors.black87),
      ),
    ],
  ),
  const SizedBox(height: 12),
],


                      /// FEATURES LIST
                      Expanded(
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: card.features.map(
                            (f) => Row(
                              children: [
                                const Icon(Icons.check,
                                    color: Color(0xFF16AE8E), size: 18),
                                const SizedBox(width: 5),
                                Expanded(child: Text(f)),
                              ],
                            ),
                          ).toList(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      FutureBuilder<bool>(
                        future: PurchaseStatusService.isPurchased(card.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final purchased = snapshot.data!;
                          if (purchased) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  height: 45,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text("Purchased",
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 380),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: SingleChildScrollView(
                                                child: SafeArea(
                                                  child: ReviewWidget(cardId: card.id),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    "Give your review",
                                    style: TextStyle(
                                      color: Colors.pinkAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Provider.of<CartProvider>(context, listen: false).addItem(
                                CartItem(
                                  id: card.id,
                                  title: card.title,
                                  imageUrl: card.imageUrl,
                                  price: int.parse(card.price),
                                  type: "membership_carousel",
                                ),
                              );
                            },
                            child: const Text("Add to Cart"),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
