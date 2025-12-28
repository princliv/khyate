import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/purchase_service.dart';   // ✅ ADD THIS IMPORT

class CartScreen extends StatefulWidget {
  final bool isDarkMode;
  const CartScreen({super.key, required this.isDarkMode});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final bg = widget.isDarkMode ? Colors.black : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final cardColor =
        widget.isDarkMode ? const Color(0xFF101822) : Colors.grey.shade100;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme:
            IconThemeData(color: widget.isDarkMode ? Colors.white : Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Cart",
              style: TextStyle(color: textColor),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showHistory = !_showHistory;
                });
              },
              child: Text(
                "History",
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.blueAccent : Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

      body: cart.items.isEmpty && !_showHistory
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add items to get started",
                    style: TextStyle(
                      fontSize: 16,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            )
          : _showHistory
              ? _buildHistoryView(context, textColor, subTextColor)
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
                              color: widget.isDarkMode ? const Color(0xFF1A2332) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                if (!widget.isDarkMode)
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
                                      maxLines: 2,
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
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: widget.isDarkMode
                                                  ? Colors.white10
                                                  : const Color(0xFFE8F0FE),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              item.type.toUpperCase(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: widget.isDarkMode
                                                    ? Colors.white70
                                                    : const Color(0xFF1A73E8),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            "AED ${item.price}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF16AE8E),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
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
                                  color: widget.isDarkMode
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
                                  widget.isDarkMode ? Colors.greenAccent : Colors.green,
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
                              widget.isDarkMode ? Colors.greenAccent : Colors.green,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          "Checkout",
                          style: TextStyle(
                              color: widget.isDarkMode ? Colors.black : Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildHistoryView(BuildContext context, Color textColor, Color subTextColor) {
    // TODO: Implement with your API
    // Example:
    // return FutureBuilder<List<Map<String, dynamic>>>(
    //   future: YourApiService.getPurchaseHistory(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(child: CircularProgressIndicator());
    //     }
    //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
    //       return Center(...);
    //     }
    //     final purchases = snapshot.data!;
    //     return ListView.builder(...);
    //   },
    // );
    
    // Stub implementation - shows empty state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 80,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No purchase history",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your past purchases will appear here",
            style: TextStyle(
              fontSize: 16,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
