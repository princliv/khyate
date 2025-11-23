import 'package:flutter/material.dart';
import 'package:khyate_b2b/models/cart_model.dart';
import 'package:khyate_b2b/providers/cart_provider.dart';
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
        width: 290,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                data.imageUrl,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFFDE7F4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          data.category,
                          style: TextStyle(
                            color: Color(0xFFDF50B7),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        data.price,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    data.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    data.description,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Color(0xFFDF50B7), size: 16),
                      SizedBox(width: 4),
                      Text(
                        data.time,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        data.mentor,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_border, color: Colors.black38, size: 16),
                      Text(
                        data.reviews,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.pinkAccent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  onPressed: () {
    Provider.of<CartProvider>(context, listen: false).addItem(
      CartItem(
        id: data.id,
        title: data.title,
        imageUrl: data.imageUrl,
        price: int.parse(data.price),
        type: "membership",
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${data.title} added to cart"))
    );
  },
  child: Text("Add to Cart"),
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
