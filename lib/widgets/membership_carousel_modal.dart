import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/models/membership_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/services/review_service.dart';
import 'package:Outbox/widgets/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembershipCarouselModal extends StatelessWidget {
  final MembershipCarouselData data;
  final bool isDarkMode;

  const MembershipCarouselModal({
    super.key,
    required this.data,
    this.isDarkMode = false,
  });

  static void show(BuildContext context, MembershipCarouselData data, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MembershipCarouselModal(data: data, isDarkMode: isDarkMode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxDialogHeight = MediaQuery.of(context).size.height * 0.85;
    final Color backgroundColor = isDarkMode ? const Color(0xFF1A2332) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1A2332);
    final Color titleColor = isDarkMode ? const Color(0xFFC5A572) : const Color(0xFF1A2332);
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color dividerColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(color: dividerColor, height: 1),
              // Image
              if (data.imageUrl.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      data.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Image.asset(
                            'assets/default_thumbnail.webp',
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: data.imageUrl.isNotEmpty ? 0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and Price
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE7F4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              data.tag,
                              style: const TextStyle(
                                color: Color(0xFFDF50B7),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "AED ${data.price}",
                            style: const TextStyle(
                              color: Color(0xFF1A2332),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Review Average
                      StreamBuilder<double>(
                        stream: ReviewService.avgRating(data.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final rating = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Row(
                                children: [
                                  Icon(
                                    rating > 0 ? Icons.star : Icons.star_border,
                                    color: rating > 0 ? Colors.amber : subTextColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rating > 0
                                        ? "Review: ${rating.toStringAsFixed(1)}"
                                        : "0 review",
                                    style: TextStyle(color: subTextColor, fontSize: 15),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              children: [
                                Icon(Icons.star_border, color: subTextColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "0 review",
                                  style: TextStyle(color: subTextColor, fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Features Section
                      Text(
                        "Features",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Features List
                      ...data.features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check,
                                color: Color(0xFF16AE8E),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Details Section
                      Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Trainer
                      if (data.mentor.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Color(0xFFDF50B7), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Trainer: ${data.mentor}",
                                style: TextStyle(color: subTextColor, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      // Date
                      if (data.date.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFFDF50B7), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Date: ${data.date}",
                                style: TextStyle(color: subTextColor, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      // Location
                      if (data.location.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFFDF50B7), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Location: ${data.location}",
                                  style: TextStyle(color: subTextColor, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder<Map<String, dynamic>?>(
  future: ReviewService.getUserReview(data.id),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return SizedBox(); // loading or no review
    }

    final userReview = snapshot.data;
    if (userReview == null) {
      return SizedBox(); // user never reviewed
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "Your Review",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2332),
          ),
        ),

        SizedBox(height: 8),

        // Rating
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 6),
            Text(
              userReview['rating'].toString(),
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),

        SizedBox(height: 6),

        // Comment
        Text(
          userReview['comment'] ?? "",
          style: TextStyle(
            fontSize: 15,
            color: textColor,
          ),
        ),

        SizedBox(height: 20),
      ],
    );
  },
),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Add to Cart / Purchased Button Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FutureBuilder<bool>(
                  future: PurchaseStatusService.isPurchased(data.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(
                        height: 90,
                        child: Center(child: CircularProgressIndicator(color: titleColor)),
                      );
                    }

                    final purchased = snapshot.data!;
                    final cartItems = Provider.of<CartProvider>(context).items;
                    final isInCart = cartItems.any((item) => item.id == data.id);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 45,
                          child: purchased
                              ? Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Purchased",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : isInCart
                                  ? Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F7E9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "Added",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
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
                                      ),
                                      onPressed: () {
                                        Provider.of<CartProvider>(context, listen: false).addItem(
                                          CartItem(
                                            id: data.id,
                                            title: data.title,
                                            imageUrl: data.imageUrl.isNotEmpty
                                                ? data.imageUrl
                                                : 'assets/default_thumbnail.webp',
                                            price: int.parse(data.price),
                                            type: "membership_carousel",
                                          ),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("${data.title} added to cart")),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Add to Cart"),
                                    ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 36,
                          child: purchased
                              ? TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          insetPadding:
                                              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20)),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 380),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: SingleChildScrollView(
                                                child: SafeArea(
                                                  child: ReviewWidget(cardId: data.id),
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
                                )
                              : isInCart
                                  ? TextButton(
                                      onPressed: () {
                                        Provider.of<CartProvider>(context, listen: false)
                                            .removeItem(data.id);
                                      },
                                      child: const Text(
                                        "Remove",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Close button at bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6767),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

