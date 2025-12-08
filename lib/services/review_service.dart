import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  static Future<void> submitReview({
    required String cardId,
    required double rating,
    required String comment,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("reviews")
        .doc(cardId)
        .collection("userReviews")
        .doc(uid)
        .set({
      "rating": rating,
      "comment": comment,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Stream<double> avgRating(String cardId) {
    return FirebaseFirestore.instance
        .collection("reviews")
        .doc(cardId)
        .collection("userReviews")
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;

      double total = 0;
      for (var doc in snapshot.docs) {
        total += doc["rating"];
      }
      return total / snapshot.docs.length;
    });
  }
  static Future<Map<String, dynamic>?> getUserReview(String cardId) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final doc = await FirebaseFirestore.instance
      .collection("reviews")
      .doc(cardId)
      .collection("userReviews")
      .doc(uid)
      .get();

  return doc.exists ? doc.data() : null;
}

}
