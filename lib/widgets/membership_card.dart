import 'package:Outbox/models/cart_model.dart';
import 'package:Outbox/providers/cart_provider.dart';
import 'package:Outbox/services/purchase_status_service.dart';
import 'package:Outbox/widgets/review_widget.dart';
import 'package:flutter/material.dart';
// import 'package:khyate_b2b/models/cart_model.dart';
// import 'package:khyate_b2b/providers/cart_provider.dart';
// import 'package:khyate_b2b/services/purchase_status_service.dart';
// import 'package:khyate_b2b/widgets/review_widget.dart';
import 'package:provider/provider.dart';
import '../models/membership_card_model.dart';   // <-- USE MODEL FROM MODELS FOLDER

class MembershipCard extends StatelessWidget {
  final MembershipCardData data;
  final VoidCallback? onTap;

  const MembershipCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                data.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY + PRICE ROW
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Color(0xFFFDE7F4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          data.category,
                          style: TextStyle(
                            color: Color(0xFFDF50B7),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "AED ${data.price}",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // TITLE
                  Text(
                    data.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // DESCRIPTION
                  Text(
                    data.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // TIME + DATE ROW
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Color(0xFFDF50B7), size: 16),
                      SizedBox(width: 4),
                      Text(
                        data.time,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.calendar_today, color: Color(0xFFDF50B7), size: 16),
                      SizedBox(width: 4),
                      Text(
                        data.date,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // LOCATION + TRAINER ROW
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFFDF50B7), size: 14),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data.location,
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        data.mentor,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // REVIEWS
                  Row(
                    children: [
                      Icon(Icons.star_border, color: Colors.black38, size: 16),
                      Text(
                        data.reviews,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ADD TO CART / PURCHASED BUTTON
                  FutureBuilder<bool>(
                    future: PurchaseStatusService.isPurchased(data.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox(
                          height: 90,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final purchased = snapshot.data!;

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
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFE3EE),
                                      foregroundColor: const Color(0xFFD81B60),
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
                                          id: data.id,
                                          title: data.title,
                                          imageUrl: data.imageUrl,
                                          price: int.parse(data.price),
                                          type: "membership",
                                        ),
                                      );

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("${data.title} added to cart")),
                                      );
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
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) {
                                          return Dialog(
                                            insetPadding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 24),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)),
                                            child: ConstrainedBox(
                                              constraints:
                                                  const BoxConstraints(maxWidth: 380),
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
                                : const SizedBox.shrink(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
