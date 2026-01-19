import 'dart:io';
import 'api_service.dart';

class PackageService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // 15.1 Create Package
  // Note: Backend model expects duration as enum ('daily', 'weekly', 'monthly') and numberOfClasses
  // API docs show duration as number, but backend model is the source of truth
  Future<Map<String, dynamic>?> createPackage({
    File? image,
    String? imageUrl,
    required String name,
    required String description,
    required double price,
    required String duration, // Changed from int to String: 'daily', 'weekly', or 'monthly'
    required int numberOfClasses, // Changed from classesIncluded to numberOfClasses to match backend model
    required bool isActive,
  }) async {
    try {
      // Validate duration enum
      final validDurations = ['daily', 'weekly', 'monthly'];
      if (!validDurations.contains(duration.toLowerCase())) {
        throw Exception('Duration must be one of: daily, weekly, monthly');
      }
      
      final fields = {
        'name': name,
        'description': description,
        'price': price.toString(),
        'duration': duration.toLowerCase(), // Backend expects enum: 'daily', 'weekly', 'monthly'
        'numberOfClasses': numberOfClasses.toString(), // Backend model field name
        'isActive': isActive.toString(),
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/package/create-package',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create package');
      }
    } catch (e) {
      throw Exception('Create package error: ${e.toString()}');
    }
  }
  
  // 15.2 Update Package
  Future<Map<String, dynamic>?> updatePackage({
    required String packageId,
    File? image,
    String? name,
    double? price,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (name != null) fields['name'] = name;
      if (price != null) fields['price'] = price.toString();
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/package/update-package/$packageId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update package');
      }
    } catch (e) {
      throw Exception('Update package error: ${e.toString()}');
    }
  }
  
  // 15.3 Get All Packages
  Future<Map<String, dynamic>?> getAllPackages({
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
        '$baseUrl/package/get-all-packages',
        payload,
        requireAuth: false, // Public route
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get packages');
      }
    } catch (e) {
      throw Exception('Get all packages error: ${e.toString()}');
    }
  }
  
  // 15.4 Get Package by ID
  Future<Map<String, dynamic>?> getPackageById({
    required String packageId,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/package/get-package-by-id/$packageId',
        requireAuth: false, // Public route
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get package');
      }
    } catch (e) {
      throw Exception('Get package by ID error: ${e.toString()}');
    }
  }
  
  // 15.5 Delete Package (Admin only)
  Future<Map<String, dynamic>?> deletePackage({
    required String packageId,
  }) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/package/delete-package/$packageId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to delete package');
      }
    } catch (e) {
      throw Exception('Delete package error: ${e.toString()}');
    }
  }
}

