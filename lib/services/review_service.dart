import 'api_service.dart';

class ReviewService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 2.6 Create Subscription Rating Review
  Future<Map<String, dynamic>?> createSubscriptionReview({
    required String subscriptionId,
    required int rating,
    required String review,
    List<String>? images,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/user/create-subscription-rating-review',
        {
          'subscriptionId': subscriptionId,
          'rating': rating,
          'review': review,
          if (images != null && images.isNotEmpty) 'images': images,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to create review');
      }
    } catch (e) {
      throw Exception('Create subscription review error: ${e.toString()}');
    }
  }
  
  // 2.7 Update Subscription Review
  Future<Map<String, dynamic>?> updateSubscriptionReview({
    required String subscriptionId,
    int? rating,
    String? review,
    List<String>? images,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (rating != null) payload['rating'] = rating;
      if (review != null) payload['review'] = review;
      if (images != null) payload['images'] = images;
      
      final response = await ApiService.put(
        '$baseUrl/user/update-subscription-review/$subscriptionId',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to update review');
      }
    } catch (e) {
      throw Exception('Update subscription review error: ${e.toString()}');
    }
  }
  
  // 2.8 Create Trainer Rating Review
  Future<Map<String, dynamic>?> createTrainerReview({
    required String trainerId,
    required int rating,
    required String review,
    List<String>? images,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/user/create-trainer-rating-review',
        {
          'trainerId': trainerId,
          'rating': rating,
          'review': review,
          if (images != null && images.isNotEmpty) 'images': images,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to create trainer review');
      }
    } catch (e) {
      throw Exception('Create trainer review error: ${e.toString()}');
    }
  }
  
  // 2.9 Update Trainer Review
  Future<Map<String, dynamic>?> updateTrainerReview({
    required String trainerId,
    int? rating,
    String? review,
    List<String>? images,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (rating != null) payload['rating'] = rating;
      if (review != null) payload['review'] = review;
      if (images != null) payload['images'] = images;
      
      final response = await ApiService.put(
        '$baseUrl/user/update-trainer-review/$trainerId',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to update trainer review');
      }
    } catch (e) {
      throw Exception('Update trainer review error: ${e.toString()}');
    }
  }
  
  // 2.10 Reply to Trainer Review (Admin)
  Future<Map<String, dynamic>?> replyToTrainerReview({
    required String reviewId,
    required String reply,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/user/admin-reply-trainer-review/$reviewId',
        {'reply': reply},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to reply to review');
      }
    } catch (e) {
      throw Exception('Reply to trainer review error: ${e.toString()}');
    }
  }
  
  // 2.11 Reply to Subscription Review (Admin)
  Future<Map<String, dynamic>?> replyToSubscriptionReview({
    required String reviewId,
    required String reply,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/user/reply-subscription-review/$reviewId',
        {'reply': reply},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to reply to review');
      }
    } catch (e) {
      throw Exception('Reply to subscription review error: ${e.toString()}');
    }
  }
  
  // 2.12 Toggle Trainer Review Visibility (Admin)
  Future<Map<String, dynamic>?> toggleTrainerReviewVisibility({
    required String reviewId,
    required bool isHidden,
  }) async {
    try {
      final response = await ApiService.put(
        '$baseUrl/user/admin-hide-trainer-review/$reviewId',
        {'isHidden': isHidden},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to toggle review visibility');
      }
    } catch (e) {
      throw Exception('Toggle trainer review visibility error: ${e.toString()}');
    }
  }
  
  // 2.13 Toggle Subscription Review Visibility (Admin)
  Future<Map<String, dynamic>?> toggleSubscriptionReviewVisibility({
    required String reviewId,
    required bool isHidden,
  }) async {
    try {
      final response = await ApiService.put(
        '$baseUrl/user/review-subscription-visibility/$reviewId',
        {'isHidden': isHidden},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to toggle review visibility');
      }
    } catch (e) {
      throw Exception('Toggle subscription review visibility error: ${e.toString()}');
    }
  }
  
  // Legacy methods for compatibility
  static Future<void> submitReview({
    required String cardId,
    required double rating,
    required String comment,
  }) async {
    final service = ReviewService();
    await service.createSubscriptionReview(
      subscriptionId: cardId,
      rating: rating.toInt(),
      review: comment,
    );
  }

  static Stream<double> avgRating(String cardId) {
    // TODO: Implement with actual API endpoint if available
    return Stream.value(0.0);
  }
  
  static Future<Map<String, dynamic>?> getUserReview(String cardId) async {
    // TODO: Implement with actual API endpoint if available
    return null;
  }
}
