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
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] is List) {
          return data['data'];
        } else if (data is Map && data['countries'] is List) {
          return data['countries'];
        }
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get countries');
      }
    } catch (e) {
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
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] is List) {
          return data['data'];
        } else if (data is Map && data['cities'] is List) {
          return data['cities'];
        }
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get cities');
      }
    } catch (e) {
      throw Exception('Get cities error: ${e.toString()}');
    }
  }
}

