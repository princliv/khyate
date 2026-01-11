import 'api_service.dart';

class MasterDataService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Get all countries
  Future<List<dynamic>> getAllCountries() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-country',
        requireAuth: false,
      );
      
      // Debug: Print response structure
      print('Countries API Response: $response');
      
      if (response['success'] == true) {
        final data = response['data'];
        
        // Handle different response structures
        // Backend returns: { statusCode, data: [...], message, success }
        // ApiService wraps it: { success: true, data: { statusCode, data: [...], message, success } }
        
        if (data is List) {
          return data;
        } else if (data is Map) {
          // Check for nested data structure from ApiResponse
          if (data['data'] is List) {
            return data['data'];
          } else if (data['countries'] is List) {
            return data['countries'];
          }
          // If data is a Map but doesn't have 'data' or 'countries', log it
          print('Unexpected response structure: $data');
        }
        
        // If we get here, the structure is unexpected
        print('No countries found in response. Response structure: ${response.toString()}');
        return [];
      } else {
        final errorMsg = response['error'] ?? 'Failed to get countries';
        print('Countries API Error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Get countries exception: ${e.toString()}');
      // Provide more detailed error message
      if (e.toString().contains('Failed to fetch') || 
          e.toString().contains('NetworkError') ||
          e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please ensure the backend server is running on http://localhost:5000');
      }
      throw Exception('Get countries error: ${e.toString()}');
    }
  }
  
  // Get cities by country ID
  Future<List<dynamic>> getCitiesByCountry(String countryId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-city/$countryId',
        requireAuth: false,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        // Backend returns: { statusCode, data: [...], message, success }
        // ApiService wraps it: { success: true, data: { statusCode, data: [...], message, success } }
        if (data is List) {
          return data;
        } else if (data is Map) {
          // Check for nested data structure from ApiResponse
          if (data['data'] is List) {
            return data['data'];
          } else if (data['cities'] is List) {
            return data['cities'];
          }
        }
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get cities');
      }
    } catch (e) {
      throw Exception('Get cities error: ${e.toString()}');
    }
  }

  // Helper method to extract data from response
  List<dynamic> _extractListFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  Map<String, dynamic>? _extractMapFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return null;
  }

  // 3.1 Get Latest Terms & Policy
  Future<Map<String, dynamic>?> getLatestTerms() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-latest-terms',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractMapFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get terms');
      }
    } catch (e) {
      throw Exception('Get terms error: ${e.toString()}');
    }
  }

  // Get Latest Privacy Policy
  Future<Map<String, dynamic>?> getLatestPrivacy() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-latest-privacy',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractMapFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get privacy policy');
      }
    } catch (e) {
      throw Exception('Get privacy policy error: ${e.toString()}');
    }
  }

  // 3.3 Get All Tenures
  Future<List<dynamic>> getAllTenures() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-tenure',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get tenures');
      }
    } catch (e) {
      throw Exception('Get tenures error: ${e.toString()}');
    }
  }

  // 3.7 Get All Tax Masters
  Future<List<dynamic>> getAllTaxMasters({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/master/get-all-tax-master',
        {
          'page': page,
          'limit': limit,
        },
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get tax masters');
      }
    } catch (e) {
      throw Exception('Get tax masters error: ${e.toString()}');
    }
  }

  // 3.10 Get All Location Masters
  Future<List<dynamic>> getAllLocationMasters({
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
        '$baseUrl/master/get-all-location-master',
        payload,
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get locations');
      }
    } catch (e) {
      throw Exception('Get locations error: ${e.toString()}');
    }
  }

  // 3.11 Get Locations by Country and City
  Future<List<dynamic>> getLocationsByCountryCity({
    required String countryId,
    required String cityId,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-location-by-country-city',
        requireAuth: false,
        queryParams: {
          'country': countryId,
          'city': cityId,
        },
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get locations');
      }
    } catch (e) {
      throw Exception('Get locations by country/city error: ${e.toString()}');
    }
  }

  // Get All Sessions
  Future<List<dynamic>> getAllSessions() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-session',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get sessions');
      }
    } catch (e) {
      throw Exception('Get sessions error: ${e.toString()}');
    }
  }

  // Get Session by ID
  Future<Map<String, dynamic>?> getSessionById(String sessionId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-session-by-id/$sessionId',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractMapFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get session');
      }
    } catch (e) {
      throw Exception('Get session error: ${e.toString()}');
    }
  }

  // Get Sessions by Category ID
  Future<List<dynamic>> getSessionsByCategoryId(String categoryId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-session-by-category-id/$categoryId',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get sessions');
      }
    } catch (e) {
      throw Exception('Get sessions by category error: ${e.toString()}');
    }
  }

  // Get All Categories
  Future<List<dynamic>> getAllCategories() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-category',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get categories');
      }
    } catch (e) {
      throw Exception('Get categories error: ${e.toString()}');
    }
  }

  // Get Category by ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-category-by-id/$categoryId',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractMapFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get category');
      }
    } catch (e) {
      throw Exception('Get category error: ${e.toString()}');
    }
  }

  // Get All Roles
  Future<List<dynamic>> getAllRoles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/master/get-all-role',
        {
          'page': page,
          'limit': limit,
        },
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get roles');
      }
    } catch (e) {
      throw Exception('Get roles error: ${e.toString()}');
    }
  }

  // Get All Active Roles
  Future<List<dynamic>> getAllActiveRoles() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-active-role',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get active roles');
      }
    } catch (e) {
      throw Exception('Get active roles error: ${e.toString()}');
    }
  }
}

