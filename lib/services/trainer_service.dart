import 'dart:io';
import 'dart:convert';
import 'api_service.dart';

class TrainerService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 5.1 Create Trainer
  Future<Map<String, dynamic>?> createTrainer({
    required File? profileImage,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String emiratesId,
    required String gender,
    required String address,
    required int age,
    required String country,
    required String city,
    required String specialization,
    required String experience,
    required int experienceYear,
    required String password,
    required List<String> serviceProvider,
  }) async {
    try {
      // Build fields map - trim all string fields and ensure proper formatting
      // Gender must be: "Male", "Female", "Others" (capitalized)
      // Experience must be: "EXPERIENCE" or "FRESHER"
      // Note: emirates_id is required by backend User model, even though not in API docs
      final trimmedEmiratesId = emiratesId.trim();
      if (trimmedEmiratesId.isEmpty) {
        throw Exception('Emirates ID is required by the backend model');
      }
      
      final fields = <String, dynamic>{
        'email': email.trim(),
        'first_name': firstName.trim(),
        'phone_number': phoneNumber.trim(),
        'emirates_id': trimmedEmiratesId,
        'password': password,
      };
      
      // Fix gender to match enum: "Male", "Female", "Others"
      String normalizedGender = gender.trim();
      if (normalizedGender.toLowerCase() == 'male') {
        normalizedGender = 'Male';
      } else if (normalizedGender.toLowerCase() == 'female') {
        normalizedGender = 'Female';
      } else if (normalizedGender.toLowerCase() == 'other' || normalizedGender.toLowerCase() == 'others') {
        normalizedGender = 'Others';
      }
      
      // Fix experience to match enum: "EXPERIENCE" or "FRESHER"
      String normalizedExperience = experience.trim().toUpperCase();
      if (normalizedExperience == 'YES' || normalizedExperience == 'EXPERIENCED' || normalizedExperience == 'HAS EXPERIENCE') {
        normalizedExperience = 'EXPERIENCE';
      } else if (normalizedExperience == 'NO' || normalizedExperience == 'FRESH' || normalizedExperience == 'NEW') {
        normalizedExperience = 'FRESHER';
      }
      
      // Add optional fields - send them if provided (backend handles undefined)
      if (lastName.trim().isNotEmpty) {
        fields['last_name'] = lastName.trim();
      }
      if (normalizedGender.isNotEmpty) {
        fields['gender'] = normalizedGender;
      }
      if (address.trim().isNotEmpty) {
        fields['address'] = address.trim();
      }
      if (age > 0) {
        fields['age'] = age.toString();
      }
      if (country.trim().isNotEmpty) {
        fields['country'] = country.trim();
      }
      if (city.trim().isNotEmpty) {
        fields['city'] = city.trim();
      }
      if (specialization.trim().isNotEmpty) {
        fields['specialization'] = specialization.trim();
      }
      if (normalizedExperience.isNotEmpty) {
        fields['experience'] = normalizedExperience;
      }
      if (experienceYear >= 0) { // Allow 0 years of experience
        fields['experienceYear'] = experienceYear.toString();
      }
      
      // Handle serviceProvider - send as JSON string (empty array is valid)
      fields['serviceProvider'] = jsonEncode(serviceProvider);
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/trainer/create-trainer',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        // Backend returns { statusCode, data, message, success }
        // Our ApiService wraps it, so data might be the full response or just the data field
        final responseData = response['data'];
        if (responseData is Map && responseData.containsKey('data')) {
          return responseData['data'];
        }
        return responseData;
      } else {
        // Extract error message from response - check multiple possible locations
        String errorMsg = response['error'] ?? 
                        response['data']?['message'] ?? 
                        response['data']?['error'] ?? 
                        response['data']?['msg'] ??
                        (response['data'] is String ? response['data'] : null) ??
                        'Failed to create trainer';
        
        // Check if error contains validation errors and extract them
        if (response['data'] is Map) {
          final data = response['data'] as Map;
          if (data.containsKey('errors') && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            final errorList = errors.entries.map((e) => '${e.key}: ${e.value}').join(', ');
            if (errorList.isNotEmpty) {
              errorMsg = errorList;
            }
          }
        }
        
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Create trainer error: ${e.toString()}');
    }
  }
  
  // 5.2 Update Trainer
  Future<Map<String, dynamic>?> updateTrainer({
    required String trainerId,
    File? profileImage,
    String? firstName,
    String? lastName,
    String? specialization,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (firstName != null) fields['first_name'] = firstName;
      if (lastName != null) fields['last_name'] = lastName;
      if (specialization != null) fields['specialization'] = specialization;
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/trainer/update-trainer/$trainerId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update trainer');
      }
    } catch (e) {
      throw Exception('Update trainer error: ${e.toString()}');
    }
  }
  
  // 5.3 Update Trainer Status
  Future<Map<String, dynamic>?> updateTrainerStatus({
    required String trainerId,
    required String status,
  }) async {
    try {
      final response = await ApiService.patch(
        '$baseUrl/trainer/update-trainer-status/$trainerId',
        {'status': status},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update trainer status');
      }
    } catch (e) {
      throw Exception('Update trainer status error: ${e.toString()}');
    }
  }
  
  // 5.4 Update Trainer Profile (By Trainer)
  Future<Map<String, dynamic>?> updateTrainerProfile({
    required String trainerId,
    File? profileImage,
    String? firstName,
    String? lastName,
    String? specialization,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (firstName != null) fields['first_name'] = firstName;
      if (lastName != null) fields['last_name'] = lastName;
      if (specialization != null) fields['specialization'] = specialization;
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/trainer/update-trainer-profiles/$trainerId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update trainer profile');
      }
    } catch (e) {
      throw Exception('Update trainer profile error: ${e.toString()}');
    }
  }
  
  // 5.5 Get All Assigned Jobs
  Future<Map<String, dynamic>?> getAllAssignedJobs({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final payload = {
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
      };
      
      final response = await ApiService.post(
        '$baseUrl/trainer/get-all-assigned-jobs',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get assigned jobs');
      }
    } catch (e) {
      throw Exception('Get assigned jobs error: ${e.toString()}');
    }
  }
  
  // 5.6 Trainer Check-in
  Future<Map<String, dynamic>?> checkin({
    required String orderDetailsId,
    required String checkinTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/trainer/checkin/$orderDetailsId',
        {
          'checkinTime': checkinTime,
          'latitude': latitude,
          'longitude': longitude,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to check-in');
      }
    } catch (e) {
      throw Exception('Check-in error: ${e.toString()}');
    }
  }
  
  // 5.7 Initiate Checkout
  Future<Map<String, dynamic>?> initiateCheckout({
    required String orderDetailsId,
    String? notes,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/trainer/initiate-checkout/$orderDetailsId',
        {
          if (notes != null) 'notes': notes,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to initiate checkout');
      }
    } catch (e) {
      throw Exception('Initiate checkout error: ${e.toString()}');
    }
  }
  
  // 5.8 Complete Checkout
  Future<Map<String, dynamic>?> completeCheckout({
    required String orderDetailsId,
    required String completionTime,
    required List<String> images,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/trainer/complete-checkout/$orderDetailsId',
        {
          'completionTime': completionTime,
          'images': images,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to complete checkout');
      }
    } catch (e) {
      throw Exception('Complete checkout error: ${e.toString()}');
    }
  }
  
  // Get All Trainers
  Future<List<dynamic>> getAllTrainers() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/trainer/get-all-trainers',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
        if (data is Map && data['trainers'] is List) return data['trainers'];
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get trainers');
      }
    } catch (e) {
      throw Exception('Get trainers error: ${e.toString()}');
    }
  }
}

