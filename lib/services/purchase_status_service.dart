import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PurchaseStatusService {
  static Future<bool> isPurchased(String cardId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("purchases")
        .doc(cardId)
        .get();

    return doc.exists;
  }
}
