import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/models/membership_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/services/review_service.dart';
import 'package:Outbox/widgets/review_widget.dart';
import 'package:Outbox/widgets/membership_carousel_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/package_service.dart';

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

  /// Fetches packages using API endpoint 15.3: POST /api/v1/package/get-all-packages
  /// Request body: {page: 1, limit: 50, search: "query"}
  Future<List<MembershipCarouselData>> _fetchPackages() async {
    try {
      final packageService = PackageService();
      // API Endpoint: POST /api/v1/package/get-all-packages
      // Body: {page, limit, search}
      final result = await packageService.getAllPackages(page: 1, limit: 50, search: searchQuery.isEmpty ? null : searchQuery);
      final packages = result?['packages'] ?? result?['data'] ?? [];
      
      return packages.map<MembershipCarouselData>((pkg) {
        final id = pkg['_id']?.toString() ?? pkg['id']?.toString() ?? '';
        // Extract duration (daily/weekly/monthly) and numberOfClasses
        final duration = pkg['duration']?.toString().toLowerCase() ?? 'weekly';
        final numberOfClasses = pkg['numberOfClasses'] ?? pkg['classesIncluded'] ?? 0;
        List<String> featuresList = [];
        if (pkg['features'] is List) {
          featuresList = (pkg['features'] as List).map((e) => e.toString()).toList();
        } else if (pkg['description'] != null) {
          featuresList = [pkg['description'].toString()];
        }
        
        return MembershipCarouselData(
          id: id,
          title: pkg['name'] ?? 'Package',
          type: duration, // Use duration as type (daily/weekly/monthly)
          tag: duration, // Use duration as tag
          price: pkg['price']?.toString() ?? '0',
          mentor: '', // Packages don't have trainers
          date: '', // Packages don't have specific dates
          location: '', // Packages don't have locations
          imageUrl: pkg['image'] ?? pkg['imageUrl'] ?? '',
          classes: numberOfClasses.toString(),
          isPurchased: false, // Will be checked by PurchaseStatusService
          features: featuresList,
        );
      }).toList();
    } catch (e) {
      print('Error fetching packages: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MembershipCarouselData>>(
      future: _fetchPackages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Find Your New Latest Packages",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFF21C8B1) : const Color(0xFF353535),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }

        // Map API data to MembershipCarouselData
        final items = snapshot.data ?? [];

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
    // Use fitness screen colors: Teal (#21C8B1) for fitness
    final Color headlineColor = isDarkMode ? const Color(0xFF21C8B1) : const Color(0xFF353535);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        // Section Title
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
          "Find Your New Latest Packages",
          style: TextStyle(
              fontSize: 32,
            fontWeight: FontWeight.bold,
            color: headlineColor,
          ),
          ),
        ),
        const SizedBox(height: 20),
        // Show packages or empty state
        items.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    "No packages available",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
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
    final Color cardColor = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF5F5DC); // Beige/pale background
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF353535);
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.grey[700]!;
    final Color accentColor = const Color(0xFF21C8B1); // Teal for Fitness
    
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          MembershipCarouselModal.show(context, card, isDarkMode);
        },
        child: SizedBox(
          height: 520,
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
              /// IMAGE with OVERLAY and TAGS
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: card.imageUrl.isNotEmpty
                        ? Image.network(
                            card.imageUrl,
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
                  // Gradient overlay for better text visibility
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                    ),
                  ),
                  // Tags positioned at bottom of image
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: [
                        // Duration tag (daily/weekly/monthly)
                        Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                            card.type,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                              color: Color(0xFF353535),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Classes count tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${card.classes} Classes',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                        ),
                      ),
                      ],
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
                  const SizedBox(height: 16),

                  // Package Title
                  Text(
                    card.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price with "/package" suffix
                  Row(
                    children: [
                      Text(
                        "AED ${card.price}",
                          style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "/package",
                        style: TextStyle(
                          fontSize: 14,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Features List with checkmarks
                  if (card.features.isNotEmpty) ...[
                    ...card.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: accentColor,
                                        ),
                          const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                              feature,
                                            style: TextStyle(
                                fontSize: 14,
                                              color: textColor,
                                            ),
                                ),
                            ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                  ],

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

                          // "Buy Now" button styling to match image
                          return SizedBox(
                            height: 45,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor, // Teal color
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  fontSize: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
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
                              child: const Text("Buy Now"),
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
