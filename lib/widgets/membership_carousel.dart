import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/models/membership_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/services/review_service.dart';
import 'package:Outbox/widgets/review_widget.dart';
import 'package:Outbox/widgets/membership_carousel_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembershipCarousel extends StatelessWidget {
  final String searchQuery;
  final String? selectedTrainer;
  final bool filterFutureDate;
  final bool isDarkMode;

  const MembershipCarousel({
    super.key,
    this.searchQuery = '',
    this.selectedTrainer,
    this.filterFutureDate = false,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with your API stream
    return StreamBuilder<List<MembershipCarouselData>>(
      stream: Stream.value([]), // Stub - replace with YourApiService.getMembershipsStream()
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No memberships found"));
        }

        // Map API data to MembershipCarouselData
        final items = snapshot.data!;

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

        return _buildCarousel(filteredItems, context, isDarkMode);
      },
    );
  }

  Widget _buildCarousel(List<MembershipCarouselData> items, BuildContext context, bool isDarkMode) {
    final Color headlineColor = isDarkMode ? const Color(0xFFC5A572) : Colors.black;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "Find Your New Latest Packages",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: headlineColor,
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
                  (item) => _buildCard(item, context, isDarkMode),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(MembershipCarouselData card, BuildContext context, bool isDarkMode) {
    final Color cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.grey[700]!;
    
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          MembershipCarouselModal.show(context, card, isDarkMode);
        },
        child: SizedBox(
          height: 470,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
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
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: textColor),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.title,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "AED ${card.price}",
                        style: TextStyle(fontSize: 13, color: subTextColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// DETAILS SECTION - Better organized layout
                  if (card.mentor.isNotEmpty || card.date.isNotEmpty || card.location.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
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
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: textColor,
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
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: textColor,
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
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
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

                  // REVIEW AVERAGE
                  StreamBuilder<double>(
                    stream: ReviewService.avgRating(card.id),
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
                              style: TextStyle(color: subTextColor, fontSize: 13),
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
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                      const Spacer(),

                      FutureBuilder<bool>(
                        future: PurchaseStatusService.isPurchased(card.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final purchased = snapshot.data!;

                          return Consumer<CartProvider>(
                            builder: (context, cart, child) {
                              final isInCart = cart.items.any((item) => item.id == card.id);

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
                                      cart.removeItem(card.id);
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
                                cart.addItem(
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
      ),
    );
  }
}
