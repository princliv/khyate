import 'api_service.dart';
import 'auth_service.dart';

class PackageBookingService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 16.1 Create Package Booking
  Future<Map<String, dynamic>?> createPackageBooking({
    required String packageId,
    String? paymentMethod,
    String? promoCode,
  }) async {
    try {
      final payload = {
        'packageId': packageId,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (promoCode != null) 'promoCode': promoCode,
      };
      
      final response = await ApiService.post(
        '$baseUrl/package-booking/create-package-booking',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create package booking');
      }
    } catch (e) {
      throw Exception('Create package booking error: ${e.toString()}');
    }
  }
  
  // 16.2 Join Class with Package
  Future<Map<String, dynamic>?> joinClassWithPackage({
    required String packageBookingId,
    required String subscriptionId,
    required String classDate,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/package-booking/package-booking-join-class',
        {
          'packageBookingId': packageBookingId,
          'subscriptionId': subscriptionId,
          'classDate': classDate,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to join class with package');
      }
    } catch (e) {
      throw Exception('Join class with package error: ${e.toString()}');
    }
  }
  
  // 16.3 Mark Class Attendance
  Future<Map<String, dynamic>?> markClassAttendance({
    required String packageBookingId,
    required String subscriptionId,
    required String attendanceStatus,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/package-booking/mark-attendance',
        {
          'packageBookingId': packageBookingId,
          'subscriptionId': subscriptionId,
          'attendanceStatus': attendanceStatus,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to mark class attendance');
      }
    } catch (e) {
      throw Exception('Mark class attendance error: ${e.toString()}');
    }
  }
  
  // Get user's package bookings
  // Note: The endpoint /my-package-bookings doesn't exist in backend router
  // Using /get-package-booking-by-user-id/:userId as alternative
  Future<List<dynamic>> getMyPackageBookings() async {
    try {
      // Get current user ID
      final authService = AuthService();
      final currentUser = await authService.getCurrentUser();
      
      if (currentUser == null) {
        return [];
      }
      
      final userId = currentUser['_id']?.toString() ?? currentUser['id']?.toString();
      if (userId == null) {
        return [];
      }
      
      // Use the existing endpoint with user ID
      final response = await ApiService.get(
        '$baseUrl/package-booking/get-package-booking-by-user-id/$userId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
        if (data is Map && data['bookings'] is List) return data['bookings'];
        return [];
      } else {
        return [];
      }
    } catch (e) {
      // If endpoint returns 404 or doesn't exist, return empty list gracefully
      // This prevents error spam in console
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('404') || 
          errorStr.contains('cannot get') || 
          errorStr.contains('not found') ||
          errorStr.contains('unauthorized')) {
        // Endpoint doesn't exist or user not authenticated - return empty list
        return [];
      }
      // For other errors, still return empty list but log it once
      // Only log if it's not a 404/not found error to avoid spam
      if (!errorStr.contains('404') && !errorStr.contains('cannot get')) {
        print('Warning: Could not fetch package bookings: $e');
      }
      return [];
    }
  }
}

