import 'api_service.dart';

class AddressService {
  static const String baseUrl = 'https://outbox.nablean.com/api/v1';
  
  // 2.4 Create Address
  Future<Map<String, dynamic>?> createAddress({
    required String name,
    required String phoneNumber,
    required String pincode,
    required String street,
    String? flatNo,
    required String cityId,
    required String countryId,
    bool isDefault = false,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/user/create-address',
        {
          'name': name,
          'phone_number': phoneNumber,
          'pincode': pincode,
          'street': street,
          if (flatNo != null) 'flat_no': flatNo,
          'city': cityId,
          'country': countryId,
          'isDefault': isDefault,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to create address');
      }
    } catch (e) {
      throw Exception('Create address error: ${e.toString()}');
    }
  }
  
  // 2.5 Update Address
  Future<Map<String, dynamic>?> updateAddress({
    required String addressId,
    String? name,
    String? street,
    bool? isDefault,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (street != null) payload['street'] = street;
      if (isDefault != null) payload['isDefault'] = isDefault;
      
      final response = await ApiService.put(
        '$baseUrl/user/update-address/$addressId',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to update address');
      }
    } catch (e) {
      throw Exception('Update address error: ${e.toString()}');
    }
  }
  
  // Get all addresses
  Future<List<dynamic>> getAllAddresses() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/user/get-all-address',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get addresses');
      }
    } catch (e) {
      throw Exception('Get addresses error: ${e.toString()}');
    }
  }
  
  // Get address by ID
  Future<Map<String, dynamic>?> getAddressById(String addressId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/user/get-address-by-id/$addressId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to get address');
      }
    } catch (e) {
      throw Exception('Get address error: ${e.toString()}');
    }
  }
  
  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/user/delete-address/$addressId',
        requireAuth: true,
      );
      
      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to delete address');
      }
    } catch (e) {
      throw Exception('Delete address error: ${e.toString()}');
    }
  }
}

