import 'dart:io';
import 'api_service.dart';

class UserProfileService {
  static const String baseUrl = 'https://outbox.nablean.com/api/v1';
  
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
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map && data['user'] is Map) {
          return Map<String, dynamic>.from(data['user'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Get user profile error: ${e.toString()}');
    }
  }
  
  // Update user profile - Note: 2.3 Update User endpoint requires multipart/form-data
  // This method uses the user/update-user endpoint which may be different from auth/update-account
  Future<Map<String, dynamic>?> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? country,
    String? birthday, // Format: YYYY-MM-DD
    String? gender,
    File? profileImage, // Changed from String? to File? for multipart upload
    String? emiratesId,
  }) async {
    try {
      final fields = <String, dynamic>{};
      
      if (firstName != null) fields['first_name'] = firstName;
      if (lastName != null) fields['last_name'] = lastName;
      if (email != null) fields['email'] = email;
      if (phoneNumber != null) fields['phone_number'] = phoneNumber;
      if (address != null) fields['address'] = address;
      if (country != null) fields['country'] = country;
      if (birthday != null) fields['birthday'] = birthday;
      if (gender != null) fields['gender'] = gender;
      if (emiratesId != null) fields['emirates_id'] = emiratesId;
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/user/update-user',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map && data['user'] is Map) {
          return Map<String, dynamic>.from(data['user'] as Map);
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

