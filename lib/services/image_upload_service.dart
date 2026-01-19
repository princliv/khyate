import 'dart:io';
import 'api_service.dart';

class ImageUploadService {
  static const String baseUrl = 'https://outbox.nablean.com/api/v1';
  
  // Upload a single image and get URL
  // Note: This assumes the backend has an image upload endpoint
  // If not available, images should be uploaded as part of multipart requests
  Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await ApiService.postMultipart(
        '$baseUrl/upload/image', // Adjust endpoint if different
        {},
        files: {'image': imageFile},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Extract URL from response - adjust based on actual API response structure
        return data['url'] ?? data['imageUrl'] ?? data['secure_url'];
      } else {
        throw Exception(response['error'] ?? 'Failed to upload image');
      }
    } catch (e) {
      // If dedicated upload endpoint doesn't exist, return null
      // The calling code should handle this
      return null;
    }
  }
  
  // Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    final urls = <String>[];
    for (final file in imageFiles) {
      try {
        final url = await uploadImage(file);
        if (url != null) {
          urls.add(url);
        }
      } catch (e) {
        // Continue with other images even if one fails
        print('Error uploading image: ${e.toString()}');
      }
    }
    return urls;
  }
}

