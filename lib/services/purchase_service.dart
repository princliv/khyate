import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';

class PurchaseService {
  static Future<void> completePurchase(List<CartItem> items) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userPurchases = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("purchases");

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var item in items) {
      final docRef = userPurchases.doc(item.id);

      batch.set(docRef, {
        "title": item.title,
        "imageUrl": item.imageUrl,
        "price": item.price,
        "type": item.type,
        "purchasedAt": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
