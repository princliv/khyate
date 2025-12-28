import 'api_service.dart';

class SubscriptionBookingService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Create subscription booking
  Future<Map<String, dynamic>?> createSubscription({
    required String subscriptionId,
    String? discountedAmount,
  }) async {
    try {
      final payload = {
        'subscription': subscriptionId,
        if (discountedAmount != null && discountedAmount.isNotEmpty) 
          'discountedAmount': discountedAmount,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/subscribe',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create subscription');
      }
    } catch (e) {
      throw Exception('Create subscription error: ${e.toString()}');
    }
  }
  
  // Get subscription details by ID
  Future<Map<String, dynamic>?> getSubscriptionDetails(String bookingId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/booking/get-booking-by-id/$bookingId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return data['data'];
        } else if (data is Map && data['booking'] is Map) {
          return data['booking'];
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to get subscription details');
      }
    } catch (e) {
      throw Exception('Get subscription details error: ${e.toString()}');
    }
  }
  
  // Get booking history (my subscriptions)
  Future<List<dynamic>> getBookingHistory() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/booking/my-subscriptions',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] is List) {
          return data['data'];
        } else if (data is Map && data['bookings'] is List) {
          return data['bookings'];
        } else if (data is Map && data['subscriptions'] is List) {
          return data['subscriptions'];
        }
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get booking history');
      }
    } catch (e) {
      throw Exception('Get booking history error: ${e.toString()}');
    }
  }
  
  // Search subscriptions
  Future<List<dynamic>> searchSubscriptions(String keyword) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/subscription/search-subscriptions',
        requireAuth: false,
        queryParams: {'keyword': keyword},
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] is List) {
          return data['data'];
        } else if (data is Map && data['subscriptions'] is List) {
          return data['subscriptions'];
        }
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to search subscriptions');
      }
    } catch (e) {
      throw Exception('Search subscriptions error: ${e.toString()}');
    }
  }
  
  // Get expired subscriptions
  Future<List<dynamic>> getExpiredSubscriptions() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/booking/get-expired-subscriptions',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] is List) {
          return data['data'];
        } else if (data is Map && data['subscriptions'] is List) {
          return data['subscriptions'];
        }
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get expired subscriptions');
      }
    } catch (e) {
      throw Exception('Get expired subscriptions error: ${e.toString()}');
    }
  }
  
  // Apply promo code to subscription
  Future<Map<String, dynamic>?> applyPromoCode({
    required String subscriptionId,
    required String promoCode,
  }) async {
    try {
      final payload = {
        'subscriptionId': subscriptionId,
        'promoCode': promoCode,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/subscription-apply-promo',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to apply promo code');
      }
    } catch (e) {
      throw Exception('Apply promo code error: ${e.toString()}');
    }
  }
}

