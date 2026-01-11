import '../models/cart_model.dart';
import 'subscription_booking_service.dart';
import 'package_booking_service.dart';

class PurchaseService {
  static Future<void> completePurchase(List<CartItem> items) async {
    final subscriptionBookingService = SubscriptionBookingService();
    final packageBookingService = PackageBookingService();
    
    for (var item in items) {
      try {
        // Determine item type and call appropriate booking API
        if (item.type == "membership" || item.type == "wellness") {
          // Create subscription booking for courses/subscriptions
          await subscriptionBookingService.createSubscription(
            subscriptionId: item.id,
            paymentMethod: "card", // TODO: Get from user selection
            promoCode: null, // TODO: Get from cart if promo code applied
          );
        } else if (item.type == "membership_carousel" || item.type == "package") {
          // Create package booking for packages
          await packageBookingService.createPackageBooking(
            packageId: item.id,
            paymentMethod: "card", // TODO: Get from user selection
            promoCode: null, // TODO: Get from cart if promo code applied
          );
        } else {
          print('Warning: Unknown cart item type: ${item.type}');
        }
      } catch (e) {
        print('Error purchasing item ${item.id}: $e');
        // Continue with other items even if one fails
        // TODO: Consider showing error to user and asking if they want to continue
        rethrow; // Re-throw to let caller handle the error
      }
    }
  }
}
