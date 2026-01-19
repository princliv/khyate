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
    required int maxUses,
    required String termsAndConditions,
    String? description,
    bool? isActive,
    bool? isValidationDate,
    String? startDate,
    String? endDate,
    int? applyOfferAfterOrders,
    double? minOrderAmount,
    double? maxDiscountAmount,
  }) async {
    try {
      final fields = <String, dynamic>{
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue.toString(),
        'maxUses': maxUses.toString(),
        'termsAndConditions': termsAndConditions,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive.toString(),
        if (isValidationDate != null) 'is_validation_date': isValidationDate.toString(),
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (applyOfferAfterOrders != null) 'apply_offer_after_orders': applyOfferAfterOrders.toString(),
        if (minOrderAmount != null) 'minOrderAmount': minOrderAmount.toString(),
        if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount.toString(),
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
    String? imageUrl,
    String? code,
    String? discountType,
    double? discountValue,
    String? description,
    bool? isActive,
    bool? isValidationDate,
    String? startDate,
    String? endDate,
    int? applyOfferAfterOrders,
    double? minOrderAmount,
    double? maxDiscountAmount,
    int? maxUses,
    String? termsAndConditions,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (code != null) fields['code'] = code;
      if (discountType != null) fields['discountType'] = discountType;
      if (discountValue != null) fields['discountValue'] = discountValue.toString();
      if (description != null) fields['description'] = description;
      if (isActive != null) fields['isActive'] = isActive.toString();
      if (isValidationDate != null) fields['is_validation_date'] = isValidationDate.toString();
      if (startDate != null) fields['startDate'] = startDate;
      if (endDate != null) fields['endDate'] = endDate;
      if (applyOfferAfterOrders != null) fields['apply_offer_after_orders'] = applyOfferAfterOrders.toString();
      if (minOrderAmount != null) fields['minOrderAmount'] = minOrderAmount.toString();
      if (maxDiscountAmount != null) fields['maxDiscountAmount'] = maxDiscountAmount.toString();
      if (maxUses != null) fields['maxUses'] = maxUses.toString();
      if (termsAndConditions != null) fields['termsAndConditions'] = termsAndConditions;
      if (imageUrl != null && imageUrl.isNotEmpty) fields['imageUrl'] = imageUrl;
      
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
  
  // 6.3 Get Promo Code by ID
  Future<Map<String, dynamic>?> getPromoCodeById({
    required String promoCodeId,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/admin/get-promo-code-by-id/$promoCodeId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get promo code');
      }
    } catch (e) {
      throw Exception('Get promo code by ID error: ${e.toString()}');
    }
  }
  
  // 6.4 Get All Promo Codes
  Future<Map<String, dynamic>?> getAllPromoCodes() async {
    try {
      // API spec says POST with no request body required
      final response = await ApiService.post(
        '$baseUrl/admin/get-all-promo-codes',
        {},
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
  
  // 6.5 Delete Promo Code
  Future<Map<String, dynamic>?> deletePromoCode({
    required String promoCodeId,
  }) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/admin/delete-promo-code/$promoCodeId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to delete promo code');
      }
    } catch (e) {
      throw Exception('Delete promo code error: ${e.toString()}');
    }
  }
  
  // 6.6 Get All Subservice Rating Reviews
  Future<Map<String, dynamic>?> getAllSubserviceRatingReviews({
    required String subServiceId,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/admin/get-all-subservice-rating-review/$subServiceId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get subservice rating reviews');
      }
    } catch (e) {
      throw Exception('Get subservice rating reviews error: ${e.toString()}');
    }
  }
  
  // 6.7 Get All Orders
  Future<Map<String, dynamic>?> getAllOrders() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/admin/get-all-orders',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get all orders');
      }
    } catch (e) {
      throw Exception('Get all orders error: ${e.toString()}');
    }
  }
  
  // 6.8 Get Dashboard Details
  Future<Map<String, dynamic>?> getDashboardDetails() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/admin/get-dashboard-details',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get dashboard details');
      }
    } catch (e) {
      throw Exception('Get dashboard details error: ${e.toString()}');
    }
  }
  
  // 6.9 Get Month Wise Data
  Future<Map<String, dynamic>?> getMonthWiseData({
    int? year,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      
      final response = await ApiService.get(
        '$baseUrl/admin/get-month-wise-data',
        requireAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get month wise data');
      }
    } catch (e) {
      throw Exception('Get month wise data error: ${e.toString()}');
    }
  }
  
  // 6.10 Get Planner Dashboard
  Future<Map<String, dynamic>?> getPlannerDashboard({
    required String bookingDate,
    String? subServiceId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'bookingDate': bookingDate,
        if (subServiceId != null) 'subServiceId': subServiceId,
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
  
  // 6.11 Get Available Groomers
  Future<Map<String, dynamic>?> getAvailableGroomers({
    required String groomerId,
    required String timeSlotId,
    required String date,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/admin/get-all-available-groomers',
        {
          'groomerId': groomerId,
          'timeSlotId': timeSlotId,
          'date': date,
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
  
  // 6.12 Get Available Groomers for Booking
  Future<Map<String, dynamic>?> getAvailableGroomersForBooking({
    required String date,
    required String timeslot,
    required String subServiceId,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/admin/get-all-available-groomers-booking',
        {
          'date': date,
          'timeslot': timeslot,
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
  
  // 6.13 Create Article
  Future<Map<String, dynamic>?> createArticle({
    File? image,
    String? imageUrl,
    required String title,
    String? description,
  }) async {
    try {
      final fields = <String, dynamic>{
        'title': title,
        if (description != null) 'description': description,
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
  
  // 6.14 Get All Articles
  Future<Map<String, dynamic>?> getAllArticles() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/admin/get-all-articals',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get all articles');
      }
    } catch (e) {
      throw Exception('Get all articles error: ${e.toString()}');
    }
  }
  
  // 6.15 Get Article by ID
  Future<Map<String, dynamic>?> getArticleById({
    required String articleId,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/admin/get-artical/$articleId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get article');
      }
    } catch (e) {
      throw Exception('Get article by ID error: ${e.toString()}');
    }
  }
  
  // 6.16 Update Article
  Future<Map<String, dynamic>?> updateArticle({
    required String articleId,
    File? image,
    String? imageUrl,
    String? title,
    String? description,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (title != null) fields['title'] = title;
      if (description != null) fields['description'] = description;
      if (imageUrl != null && imageUrl.isNotEmpty) fields['imageUrl'] = imageUrl;
      
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
  
  // 6.17 Delete Article
  Future<Map<String, dynamic>?> deleteArticle({
    required String articleId,
  }) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/admin/delete-artical/$articleId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to delete article');
      }
    } catch (e) {
      throw Exception('Delete article error: ${e.toString()}');
    }
  }
}

