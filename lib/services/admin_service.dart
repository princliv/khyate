import 'dart:io';
import 'api_service.dart';

class AdminService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 6.1 Create Promo Code
  Future<Map<String, dynamic>?> createPromoCode({
    File? image,
    String? imageUrl,
    required String code,
    required String discountType,
    required double discountValue,
    required double minOrderAmount,
    required double maxDiscountAmount,
    required String validFrom,
    required String validTo,
    required int usageLimit,
    required bool isActive,
  }) async {
    try {
      final fields = {
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue.toString(),
        'minOrderAmount': minOrderAmount.toString(),
        'maxDiscountAmount': maxDiscountAmount.toString(),
        'validFrom': validFrom,
        'validTo': validTo,
        'usageLimit': usageLimit.toString(),
        'isActive': isActive.toString(),
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/admin/create-promo-code',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create promo code');
      }
    } catch (e) {
      throw Exception('Create promo code error: ${e.toString()}');
    }
  }
  
  // 6.2 Update Promo Code
  Future<Map<String, dynamic>?> updatePromoCode({
    required String promoCodeId,
    File? image,
    double? discountValue,
    String? validTo,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (discountValue != null) fields['discountValue'] = discountValue.toString();
      if (validTo != null) fields['validTo'] = validTo;
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/admin/update-promo-code/$promoCodeId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update promo code');
      }
    } catch (e) {
      throw Exception('Update promo code error: ${e.toString()}');
    }
  }
  
  // 6.3 Get All Promo Codes
  Future<Map<String, dynamic>?> getAllPromoCodes({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final payload = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      
      final response = await ApiService.post(
        '$baseUrl/admin/get-all-promo-codes',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get promo codes');
      }
    } catch (e) {
      throw Exception('Get promo codes error: ${e.toString()}');
    }
  }
  
  // 6.4 Get Planner Dashboard
  Future<Map<String, dynamic>?> getPlannerDashboard({
    required String startDate,
    required String endDate,
    String? locationId,
  }) async {
    try {
      final payload = {
        'startDate': startDate,
        'endDate': endDate,
        if (locationId != null) 'locationId': locationId,
      };
      
      final response = await ApiService.post(
        '$baseUrl/admin/get-planner-dashboard',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get planner dashboard');
      }
    } catch (e) {
      throw Exception('Get planner dashboard error: ${e.toString()}');
    }
  }
  
  // 6.5 Get Available Groomers
  Future<Map<String, dynamic>?> getAvailableGroomers({
    required String date,
    required String timeslotId,
    required String subServiceId,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/admin/get-all-available-groomers',
        {
          'date': date,
          'timeslotId': timeslotId,
          'subServiceId': subServiceId,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get available groomers');
      }
    } catch (e) {
      throw Exception('Get available groomers error: ${e.toString()}');
    }
  }
  
  // 6.6 Get Available Groomers for Booking
  Future<Map<String, dynamic>?> getAvailableGroomersForBooking({
    required String date,
    required String timeslotId,
    required String subServiceId,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/admin/get-all-available-groomers-booking',
        {
          'date': date,
          'timeslotId': timeslotId,
          'subServiceId': subServiceId,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get available groomers for booking');
      }
    } catch (e) {
      throw Exception('Get available groomers for booking error: ${e.toString()}');
    }
  }
  
  // 6.7 Create Article
  Future<Map<String, dynamic>?> createArticle({
    File? image,
    String? imageUrl,
    required String title,
    required String content,
    required String author,
    required bool isPublished,
  }) async {
    try {
      final fields = {
        'title': title,
        'content': content,
        'author': author,
        'isPublished': isPublished.toString(),
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/admin/create-artical',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create article');
      }
    } catch (e) {
      throw Exception('Create article error: ${e.toString()}');
    }
  }
  
  // 6.8 Update Article
  Future<Map<String, dynamic>?> updateArticle({
    required String articleId,
    File? image,
    String? title,
    String? content,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (title != null) fields['title'] = title;
      if (content != null) fields['content'] = content;
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/admin/update-artical/$articleId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update article');
      }
    } catch (e) {
      throw Exception('Update article error: ${e.toString()}');
    }
  }
}

