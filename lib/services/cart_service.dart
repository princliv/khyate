import 'api_service.dart';

class CartService {
  static const String baseUrl = 'https://outbox.nablean.com/api/v1';
  
  // 2.14 Calculate Cart Total
  Future<Map<String, dynamic>?> calculateCartTotal({
    required List<String> cartItems,
    String? promoCode,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/user/cart-total-price-calculate',
        {
          'cartItems': cartItems,
          if (promoCode != null) 'promoCode': promoCode,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        return data is Map ? data : (data['data'] as Map?);
      } else {
        throw Exception(response['error'] ?? 'Failed to calculate cart total');
      }
    } catch (e) {
      throw Exception('Calculate cart total error: ${e.toString()}');
    }
  }
}

