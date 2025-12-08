import 'package:Outbox/services/review_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/widgets/review_widget.dart';

class WellnessModal extends StatelessWidget {
  final Map<String, dynamic> data;
  final String documentId;
  final bool isDarkMode;

  const WellnessModal({
    super.key,
    required this.data,
    required this.documentId,
    required this.isDarkMode,
  });

  static void show(BuildContext context, Map<String, dynamic> data, String documentId, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WellnessModal(
          data: data,
          documentId: documentId,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode ? const Color(0xFF1A2332) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1A2332);
    final Color titleColor = isDarkMode ? const Color(0xFFC5A572) : const Color(0xFF1A2332);
    final Color dividerColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final double maxDialogHeight = MediaQuery.of(context).size.height * 0.85;
    final String imageUrl = (data['imageUrl'] as String?) ?? '';

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
                        data['title'] ?? '',
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
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
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
                            return Image.asset(
                              'assets/default_thumbnail.webp',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/default_thumbnail.webp',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: imageUrl.isNotEmpty ? 0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      if (data['subtitle'] != null && (data['subtitle'] as String).isNotEmpty) ...[
                        Text(
                          data['subtitle'],
                          style: TextStyle(
                            fontSize: 16,
                            color: subTextColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Details Section
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
                                        color: Color(0xFFDF50B7),
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          data['duration'] ?? 'N/A',
                                          style: TextStyle(
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
                                        color: Color(0xFFDF50B7),
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          data['date'] ?? 'No Date',
                                          style: TextStyle(
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
                                        color: Color(0xFFDF50B7),
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          data['mentor'] ?? 'N/A',
                                          style: TextStyle(
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
                                        ? Color(0xFFDF50B7).withOpacity(0.2) 
                                        : Color(0xFFFDE7F4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "AED ${data['price'] ?? '0'}",
                                    style: TextStyle(
                                      color: titleColor,
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
                      const SizedBox(height: 20),
                      // Description
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['description'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: textColor,
                        ),
                      ),
                      FutureBuilder<Map<String, dynamic>?>(
  future: ReviewService.getUserReview(documentId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox();

    final userReview = snapshot.data;
    if (userReview == null) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Your Review",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 10),

        // ⭐ Rating
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 6),
            Text(
              userReview['rating'].toString(),
              style: TextStyle(
                fontSize: 16,
                color: subTextColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 💬 Comment
        Text(
          userReview['comment'] ?? "",
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: textColor,
          ),
        ),

        const SizedBox(height: 20),
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
                  future: PurchaseStatusService.isPurchased(documentId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(
                        height: 90,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final purchased = snapshot.data!;
                    final cartItems = Provider.of<CartProvider>(context).items;
                    final isInCart = cartItems.any((item) => item.id == documentId);

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
                                        Provider.of<CartProvider>(context, listen: false).addItem(
                                          CartItem(
                                            id: documentId,
                                            title: data['title'] ?? '',
                                            imageUrl: imageUrl.isNotEmpty
                                                ? imageUrl
                                                : 'assets/default_thumbnail.webp',
                                            price: int.tryParse(data['price']?.toString() ?? '0') ?? 0,
                                            type: "wellness",
                                          ),
                                        );

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("${data['title']} added to cart")),
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
                                                  child: ReviewWidget(cardId: documentId),
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
                                            .removeItem(documentId);
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

