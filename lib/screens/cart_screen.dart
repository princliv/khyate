import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/purchase_service.dart';   // ✅ ADD THIS IMPORT

class CartScreen extends StatelessWidget {
  final bool isDarkMode;
  const CartScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final bg = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor =
        isDarkMode ? const Color(0xFF101822) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        title: Text(
          "Your Cart",
          style: TextStyle(color: textColor),
        ),
      ),

      body: cart.items.isEmpty
          ? Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final bool isNetworkImage = item.imageUrl.startsWith('http');

                      return Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1A2332) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!isDarkMode)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: isNetworkImage
                                    ? Image.network(
                                        item.imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        item.imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 12),

                              // Title, type chip and price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? Colors.white10
                                                : const Color(0xFFE8F0FE),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            item.type.toUpperCase(),
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : const Color(0xFF1A73E8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "AED ${item.price}",
                                          style: const TextStyle(
                                            color: Color(0xFF16AE8E),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Delete button
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: isDarkMode
                                      ? Colors.redAccent
                                      : const Color(0xFFE53935),
                                ),
                                onPressed: () {
                                  cart.removeItem(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // -----------------------------
// PURCHASE HISTORY SECTION
// -----------------------------
FutureBuilder<String>(
  future: Future.value(FirebaseAuth.instance.currentUser?.uid),
  builder: (context, uidSnapshot) {
    if (!uidSnapshot.hasData) return SizedBox();

    final uid = uidSnapshot.data!;
    final purchasesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("purchases")
        .orderBy("purchasedAt", descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: purchasesRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        final purchases = snapshot.data!.docs;

        if (purchases.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "No previous purchases",
              style: TextStyle(color: textColor.withOpacity(0.6)),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                "Purchase History",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: purchases.length,
                itemBuilder: (context, index) {
                  final item = purchases[index].data() as Map<String, dynamic>;

                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(left: 16, bottom: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Color(0xFF1A2332)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            item["imageUrl"],
                            height: 100,
                            width: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Icon(Icons.error),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item["title"] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "AED ${item["price"]}",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  },
),


                // Total Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Price",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor),
                          ),
                          Text(
                            "AED ${cart.totalPrice}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.greenAccent : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      /// ------------------------------
                      ///  🔥 NEW CHECKOUT LOGIC USING SERVICE
                      /// ------------------------------
                      ElevatedButton(
                        onPressed: () async {
                          await PurchaseService.completePurchase(cart.items);

                          cart.clearCart();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Purchase successful!")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? Colors.greenAccent : Colors.green,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          "Checkout",
                          style: TextStyle(
                              color: isDarkMode ? Colors.black : Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
