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
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.black12;

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

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Image.network(item.imageUrl, width: 60),
                          title: Text(item.title,
                              style: TextStyle(color: textColor)),
                          subtitle: Text(
                            "AED ${item.price}",
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete,
                                color: isDarkMode
                                    ? Colors.redAccent
                                    : Colors.red),
                            onPressed: () {
                              cart.removeItem(item.id);
                            },
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
