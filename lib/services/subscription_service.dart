import 'dart:io';
import 'dart:convert';
import 'api_service.dart';

class SubscriptionService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 14.1 Create Subscription
  Future<Map<String, dynamic>?> createSubscription({
    File? media,
    String? mediaUrl,
    required String name,
    required String categoryId,
    required double price,
    required String trainer,
    required String sessionType,
    required String description,
    required bool isActive,
    required List<String> date,
    required String startTime,
    required String endTime,
    required String addressId, // LocationMaster ObjectId
    required bool isSingleClass,
  }) async {
    try {
      final fields = {
        'name': name,
        'categoryId': categoryId,
        'price': price.toString(),
        'trainer': trainer,
        'sessionType': sessionType,
        'description': description,
        'isActive': isActive.toString(),
        'date': jsonEncode(date),
        'startTime': startTime,
        'endTime': endTime,
        'Address': addressId, // LocationMaster ObjectId (not JSON)
        'isSingleClass': isSingleClass.toString(),
        if (mediaUrl != null && mediaUrl.isNotEmpty) 'mediaUrl': mediaUrl,
      };
      
      final files = media != null ? {'media': media} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/subscription/create-subscription',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create subscription');
      }
    } catch (e) {
      throw Exception('Create subscription error: ${e.toString()}');
    }
  }
  
  // 14.2 Update Subscription
  Future<Map<String, dynamic>?> updateSubscription({
    required String subscriptionId,
    File? media,
    String? name,
    double? price,
    String? description,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (name != null) fields['name'] = name;
      if (price != null) fields['price'] = price.toString();
      if (description != null) fields['description'] = description;
      
      final files = media != null ? {'media': media} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/subscription/update-subscription/$subscriptionId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update subscription');
      }
    } catch (e) {
      throw Exception('Update subscription error: ${e.toString()}');
    }
  }
  
  // 14.3 Get All Subscriptions
  Future<Map<String, dynamic>?> getAllSubscriptions({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? sessionTypeId,
    String? trainerId,
  }) async {
    try {
      final payload = {
        'page': page,
        'limit': limit,
        if (categoryId != null) 'categoryId': categoryId,
        if (sessionTypeId != null) 'sessionTypeId': sessionTypeId,
        if (trainerId != null) 'trainerId': trainerId,
      };
      
      final response = await ApiService.post(
        '$baseUrl/subscription/get-all-subscription',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get subscriptions');
      }
    } catch (e) {
      throw Exception('Get all subscriptions error: ${e.toString()}');
    }
  }
  
  // 14.4 Get Subscriptions by Date
  Future<Map<String, dynamic>?> getSubscriptionsByDate({
    required String date,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/subscription/get-subscriptions-by-date',
        {'date': date},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get subscriptions by date');
      }
    } catch (e) {
      throw Exception('Get subscriptions by date error: ${e.toString()}');
    }
  }
  
  // 14.5 Get Subscriptions by Coordinates
  Future<Map<String, dynamic>?> getSubscriptionsByCoordinates({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/subscription/get-subscriptions-by-coordinates',
        {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get subscriptions by coordinates');
      }
    } catch (e) {
      throw Exception('Get subscriptions by coordinates error: ${e.toString()}');
    }
  }
  
  // 14.6 Get Subscriptions by User Miles
  Future<Map<String, dynamic>?> getSubscriptionsByUserMiles({
    required double latitude,
    required double longitude,
    required double miles,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/subscription/get-subscriptions-by-coordinates',
        {
          'latitude': latitude,
          'longitude': longitude,
          'miles': miles,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get subscriptions by miles');
      }
    } catch (e) {
      throw Exception('Get subscriptions by miles error: ${e.toString()}');
    }
  }
  
  // 14.7 Get Subscriptions by Location ID
  Future<Map<String, dynamic>?> getSubscriptionsByLocationId({
    required String locationId,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/subscription/get-subscriptions-by-loc-id/$locationId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get subscriptions by location');
      }
    } catch (e) {
      throw Exception('Get subscriptions by location error: ${e.toString()}');
    }
  }
  
  // 14.8 Filter and Sort Subscriptions
  Future<Map<String, dynamic>?> filterAndSortSubscriptions({
    String? categoryId,
    String? sessionTypeId,
    String? trainerId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (categoryId != null) payload['categoryId'] = categoryId;
      if (sessionTypeId != null) payload['sessionTypeId'] = sessionTypeId;
      if (trainerId != null) payload['trainerId'] = trainerId;
      if (minPrice != null) payload['minPrice'] = minPrice;
      if (maxPrice != null) payload['maxPrice'] = maxPrice;
      if (sortBy != null) payload['sortBy'] = sortBy;
      if (sortOrder != null) payload['sortOrder'] = sortOrder;
      
      final response = await ApiService.post(
        '$baseUrl/subscription/get-subscriptions-filter',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to filter subscriptions');
      }
    } catch (e) {
      throw Exception('Filter subscriptions error: ${e.toString()}');
    }
  }
  
  // 14.9 Get Trainer Assigned Subscriptions (Filters)
  Future<Map<String, dynamic>?> getTrainerAssignedSubscriptions({
    String? status,
    String? date,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (status != null) payload['status'] = status;
      if (date != null) payload['date'] = date;
      
      final response = await ApiService.post(
        '$baseUrl/subscription/get-trainer-Assigned-Subscriptions-filters',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get trainer assigned subscriptions');
      }
    } catch (e) {
      throw Exception('Get trainer assigned subscriptions error: ${e.toString()}');
    }
  }
  
  // 14.10 Search Subscriptions
  Future<List<dynamic>> searchSubscriptions({
    required String query,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/subscription/search-subscriptions',
        requireAuth: false,
        queryParams: {'query': query},
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
        if (data is Map && data['subscriptions'] is List) return data['subscriptions'];
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to search subscriptions');
      }
    } catch (e) {
      throw Exception('Search subscriptions error: ${e.toString()}');
    }
  }
  
  // 14.11 Get Subscriptions Nearby
  Future<List<dynamic>> getSubscriptionsNearby({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/subscription/subscriptions/nearby',
        requireAuth: false,
        queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radius': radius.toString(),
        },
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
        if (data is Map && data['subscriptions'] is List) return data['subscriptions'];
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get nearby subscriptions');
      }
    } catch (e) {
      throw Exception('Get nearby subscriptions error: ${e.toString()}');
    }
  }
  
  // 14.12 Subscription Check-in
  Future<Map<String, dynamic>?> subscriptionCheckin({
    required String subscriptionId,
    required String checkinTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/subscription/subscription-check-in/$subscriptionId',
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
      throw Exception('Subscription check-in error: ${e.toString()}');
    }
  }
  
  // 14.13 Subscription Check-out
  Future<Map<String, dynamic>?> subscriptionCheckout({
    required String subscriptionId,
    required String checkoutTime,
    String? notes,
  }) async {
    try {
      final payload = {
        'checkoutTime': checkoutTime,
        if (notes != null) 'notes': notes,
      };
      
      final response = await ApiService.post(
        '$baseUrl/subscription/subscription-check-out/$subscriptionId',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to check-out');
      }
    } catch (e) {
      throw Exception('Subscription check-out error: ${e.toString()}');
    }
  }
}

