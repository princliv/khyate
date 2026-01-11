import 'api_service.dart';

class BookingService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 13.1 Create Manual Booking
  Future<Map<String, dynamic>?> createManualBooking({
    required String subServiceId,
    required String timeslotId,
    required String bookingDate,
    required String groomerId,
    required String addressId,
    required Map<String, dynamic> petDetails,
  }) async {
    try {
      final payload = {
        'subServiceId': subServiceId,
        'timeslotId': timeslotId,
        'bookingDate': bookingDate,
        'groomerId': groomerId,
        'addressId': addressId,
        'petDetails': petDetails,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/create-manual-booking',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create manual booking');
      }
    } catch (e) {
      throw Exception('Create manual booking error: ${e.toString()}');
    }
  }
  
  // 13.2 Update Manual Booking
  Future<Map<String, dynamic>?> updateBooking({
    required String bookingId,
    String? bookingDate,
    String? timeslotId,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (bookingDate != null) payload['bookingDate'] = bookingDate;
      if (timeslotId != null) payload['timeslotId'] = timeslotId;
      
      final response = await ApiService.put(
        '$baseUrl/booking/update-booking/$bookingId',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update booking');
      }
    } catch (e) {
      throw Exception('Update booking error: ${e.toString()}');
    }
  }
  
  // 13.3 Create Subscription Booking (already exists but update to match API)
  Future<Map<String, dynamic>?> createSubscriptionBooking({
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
  
  // 13.5 Apply Promo Code to Subscription (already exists in subscription_booking_service)
  // This is kept for consistency but can use the one in SubscriptionBookingService
  
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

