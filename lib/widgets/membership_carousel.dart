import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/models/membership_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/widgets/review_widget.dart';
import 'package:Outbox/widgets/membership_carousel_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        height: 470,
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
              /// IMAGE with TAG
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: card.imageUrl.isNotEmpty
                        ? Image.network(
                            card.imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/default_thumbnail.webp',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Tag positioned at top right corner
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        card.tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// DETAILS
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                  /// DETAILS SECTION - Better organized layout
                  if (card.mentor.isNotEmpty || card.date.isNotEmpty || card.location.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // First Row: Date and Location (if available)
                          if (card.date.isNotEmpty || card.location.isNotEmpty)
                            Row(
                              children: [
                                if (card.date.isNotEmpty)
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Color(0xFFDF50B7),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            card.date,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (card.date.isNotEmpty && card.location.isNotEmpty)
                                  const SizedBox(width: 12),
                                if (card.location.isNotEmpty)
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color(0xFFDF50B7),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            card.location,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          if ((card.date.isNotEmpty || card.location.isNotEmpty) && card.mentor.isNotEmpty)
                            const SizedBox(height: 10),
                          // Second Row: Trainer
                          if (card.mentor.isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Color(0xFFDF50B7),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    card.mentor,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                      const Spacer(),

                      // Know More Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            MembershipCarouselModal.show(context, card);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Know More"),
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
                          final cartItems = Provider.of<CartProvider>(context).items;
                          final isInCart = cartItems.any((item) => item.id == card.id);

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

                          if (isInCart) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  height: 45,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F7E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Added",
                                    style: TextStyle(
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
                                      Provider.of<CartProvider>(context, listen: false)
                                          .removeItem(card.id);
                                    },
                                    child: const Text(
                                      "Remove",
                                      style: TextStyle(
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A73E8), // Google blue
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Provider.of<CartProvider>(context, listen: false)
                                    .addItem(
                                  CartItem(
                                    id: card.id,
                                    title: card.title,
                                    imageUrl: card.imageUrl.isNotEmpty
                                        ? card.imageUrl
                                        : 'assets/default_thumbnail.webp',
                                    price: int.parse(card.price),
                                    type: "membership_carousel",
                                  ),
                                );
                              },
                              child: const Text("Add to Cart"),
                            ),
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
