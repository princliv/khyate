import 'api_service.dart';

class SubscriptionBookingService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 13.3 Create Subscription Booking
  Future<Map<String, dynamic>?> createSubscription({
    required String subscriptionId,
    String? paymentMethod,
    String? promoCode,
  }) async {
    try {
      final payload = {
        'subscriptionId': subscriptionId,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (promoCode != null) 'promoCode': promoCode,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/subscribe',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create subscription booking');
      }
    } catch (e) {
      throw Exception('Create subscription booking error: ${e.toString()}');
    }
  }
  
  // 13.4 Cancel Subscription Booking
  Future<Map<String, dynamic>?> cancelSubscriptionBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      final payload = {
        'bookingId': bookingId,
        if (reason != null) 'reason': reason,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/cancel-subscribe',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to cancel subscription booking');
      }
    } catch (e) {
      throw Exception('Cancel subscription booking error: ${e.toString()}');
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
          return Map<String, dynamic>.from(data);
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map && data['booking'] is Map) {
          return Map<String, dynamic>.from(data['booking'] as Map);
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
  Future<List<dynamic>> searchSubscriptions(String query) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/subscription/search-subscriptions',
        requireAuth: false,
        queryParams: {'query': query},
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
  
  // 13.5 Apply Promo Code to Subscription
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
  
  // 13.6 Mark Subscription Attendance
  Future<Map<String, dynamic>?> markSubscriptionAttendance({
    required String subscriptionId,
    required String bookingId,
    required String attendanceStatus,
  }) async {
    try {
      final payload = {
        'subscriptionId': subscriptionId,
        'bookingId': bookingId,
        'attendanceStatus': attendanceStatus,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/mark-Subscription-Attendance',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to mark subscription attendance');
      }
    } catch (e) {
      throw Exception('Mark subscription attendance error: ${e.toString()}');
    }
  }
}

