import 'api_service.dart';

class AttendanceService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Mark class attendance (Package Booking)
  Future<Map<String, dynamic>?> markClassAttendance({
    required String bookingId,
    required String classId,
    required double longitude,
    required double latitude,
  }) async {
    try {
      final payload = {
        'bookingId': bookingId,
        'classId': classId,
        'coordinates': [longitude, latitude],
      };
      
      final response = await ApiService.post(
        '$baseUrl/package-booking/mark-attendance',
        payload,
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
  
  // Mark subscription attendance
  Future<Map<String, dynamic>?> markSubscriptionAttendance({
    required String bookingId,
    required String subscriptionId,
    required double longitude,
    required double latitude,
  }) async {
    try {
      final payload = {
        'bookingId': bookingId,
        'subscriptionId': subscriptionId,
        'coordinates': [longitude, latitude],
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

