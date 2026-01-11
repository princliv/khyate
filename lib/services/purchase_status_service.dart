import 'subscription_booking_service.dart';
import 'package_booking_service.dart';

class PurchaseStatusService {
  static Future<bool> isPurchased(String cardId) async {
    if (cardId.isEmpty) return false;
    
    try {
      // Check subscription bookings
      try {
      final subscriptionBookingService = SubscriptionBookingService();
      final bookings = await subscriptionBookingService.getBookingHistory();
      
      for (var booking in bookings) {
        final subId = booking['subscriptionId'] ?? booking['subscription'];
        String? bookingSubId;
        if (subId is Map) {
          bookingSubId = subId['_id']?.toString() ?? subId['id']?.toString();
        } else {
          bookingSubId = subId?.toString();
        }
        
        if (bookingSubId == cardId) {
          return true;
        }
        }
      } catch (e) {
        // Silently handle subscription booking errors
        // Don't spam console - just continue to check packages
      }
      
      // Check package bookings
      try {
      final packageBookingService = PackageBookingService();
      final packageBookings = await packageBookingService.getMyPackageBookings();
      
      for (var booking in packageBookings) {
        final pkgId = booking['packageId'] ?? booking['package'];
        String? bookingPkgId;
        if (pkgId is Map) {
          bookingPkgId = pkgId['_id']?.toString() ?? pkgId['id']?.toString();
        } else {
          bookingPkgId = pkgId?.toString();
        }
        
        if (bookingPkgId == cardId) {
          return true;
        }
        }
      } catch (e) {
        // Silently handle package booking errors
        // Don't spam console - just return false
      }
      
      return false;
    } catch (e) {
      // Final catch-all - return false if anything goes wrong
      // Only log unexpected errors (not 404s or missing endpoints)
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('404') && 
          !errorStr.contains('cannot get') && 
          !errorStr.contains('not found')) {
      print('Error checking purchase status: $e');
      }
      return false;
    }
  }
}
