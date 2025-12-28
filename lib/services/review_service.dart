// TODO: Replace with your new API review service
import 'dart:async';

class ReviewService {
  static Future<void> submitReview({
    required String cardId,
    required double rating,
    required String comment,
  }) async {
    // TODO: Implement with your API
    throw UnimplementedError('Please implement submitReview with your API');
  }

  static Stream<double> avgRating(String cardId) {
    // TODO: Implement with your API
    // Return a stream that emits 0.0 for now - replace with actual API stream
    return Stream.value(0.0);
  }
  
  static Future<Map<String, dynamic>?> getUserReview(String cardId) async {
    // TODO: Implement with your API
    return null;
  }
}
