import 'api_service.dart';

class AttendanceService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 16.3 Mark Class Attendance (Package Booking)
  Future<Map<String, dynamic>?> markClassAttendance({
    required String packageBookingId,
    required String subscriptionId,
    required String attendanceStatus,
  }) async {
    try {
      final payload = {
        'packageBookingId': packageBookingId,
        'subscriptionId': subscriptionId,
        'attendanceStatus': attendanceStatus,
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
}

