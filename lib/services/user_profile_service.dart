import 'api_service.dart';

class UserProfileService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/user/get-userby-id/$userId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        if (data is Map) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return data['data'];
        } else if (data is Map && data['user'] is Map) {
          return data['user'];
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Get user profile error: ${e.toString()}');
    }
  }
  
  // Update user profile
  Future<Map<String, dynamic>?> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? country,
    String? birthday, // Format: YYYY-MM-DD
    String? gender,
    String? profileImage,
    String? emiratesId,
  }) async {
    try {
      final payload = <String, dynamic>{};
      
      if (firstName != null) payload['first_name'] = firstName;
      if (lastName != null) payload['last_name'] = lastName;
      if (email != null) payload['email'] = email;
      if (phoneNumber != null) payload['phone_number'] = phoneNumber;
      if (address != null) payload['address'] = address;
      if (country != null) payload['country'] = country;
      if (birthday != null) payload['birthday'] = birthday;
      if (gender != null) payload['gender'] = gender;
      if (profileImage != null) payload['profile_image'] = profileImage;
      if (emiratesId != null) payload['emirates_id'] = emiratesId;
      
      final response = await ApiService.put(
        '$baseUrl/user/update-user',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        if (data is Map) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return data['data'];
        } else if (data is Map && data['user'] is Map) {
          return data['user'];
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Update user profile error: ${e.toString()}');
    }
  }
}

