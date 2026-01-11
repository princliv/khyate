import 'dart:io';
import 'api_service.dart';

class UserManagementService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 2.1 Update User Status
  Future<Map<String, dynamic>?> updateUserStatus({
    required String userId,
    required String status, // "Approved", "Pending", "Rejected"
  }) async {
    try {
      final response = await ApiService.patch(
        '$baseUrl/user/update-user-status/$userId',
        {'status': status},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update user status');
      }
    } catch (e) {
      throw Exception('Update user status error: ${e.toString()}');
    }
  }
  
  // 2.2 Create User (Admin only) - API endpoint requires multipart/form-data
  Future<Map<String, dynamic>?> createUser({
    required File? profileImage,
    required String email,
    required String userRole, // Role ID (ObjectId or role_id)
    required String firstName,
    String? lastName,
    String? phoneNumber,
    required String emiratesId,
    String? gender,
    String? address,
    int? age,
    String? country, // Country ID (ObjectId)
    String? city, // City ID (ObjectId)
    String? specialization,
    String? experience,
    int? experienceYear,
    required String password,
  }) async {
    try {
      final fields = {
        'email': email.trim(),
        'user_role': userRole,
        'first_name': firstName.trim(),
        'emirates_id': emiratesId.trim(),
        'password': password,
      };
      
      // Add optional fields
      if (lastName != null && lastName.trim().isNotEmpty) {
        fields['last_name'] = lastName.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        fields['phone_number'] = phoneNumber.trim();
      }
      if (gender != null && gender.trim().isNotEmpty) {
        fields['gender'] = gender.trim();
      }
      if (address != null && address.trim().isNotEmpty) {
        fields['address'] = address.trim();
      }
      if (age != null && age > 0) {
        fields['age'] = age.toString();
      }
      if (country != null && country.trim().isNotEmpty) {
        fields['country'] = country.trim();
      }
      if (city != null && city.trim().isNotEmpty) {
        fields['city'] = city.trim();
      }
      if (specialization != null && specialization.trim().isNotEmpty) {
        fields['specialization'] = specialization.trim();
      }
      if (experience != null && experience.trim().isNotEmpty) {
        fields['experience'] = experience.trim();
      }
      if (experienceYear != null && experienceYear >= 0) {
        fields['experienceYear'] = experienceYear.toString();
      }
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/user/create-user',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create user');
      }
    } catch (e) {
      throw Exception('Create user error: ${e.toString()}');
    }
  }
  
  // 2.3 Update User - API endpoint requires multipart/form-data
  Future<Map<String, dynamic>?> updateUser({
    File? profileImage,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final fields = <String, dynamic>{};
      
      if (email != null && email.trim().isNotEmpty) {
        fields['email'] = email.trim();
      }
      if (firstName != null && firstName.trim().isNotEmpty) {
        fields['first_name'] = firstName.trim();
      }
      if (lastName != null && lastName.trim().isNotEmpty) {
        fields['last_name'] = lastName.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        fields['phone_number'] = phoneNumber.trim();
      }
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/user/update-user',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception('Update user error: ${e.toString()}');
    }
  }
  
  // 2.16 Cancel Order by Customer
  // Note: Backend route has double colons (::orderDetailsId) which appears to be a typo
  Future<Map<String, dynamic>?> cancelOrderByCustomer({
    required String orderDetailsId,
  }) async {
    try {
      // Note: The API docs show ::orderDetailsId (double colons) which is likely a typo
      // Using single colon as that's the standard Express.js route parameter syntax
      final response = await ApiService.put(
        '$baseUrl/user/cancel-by-customer/$orderDetailsId',
        {'bookingStatus': 'CANCEL'},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Cancel order error: ${e.toString()}');
    }
  }
}

