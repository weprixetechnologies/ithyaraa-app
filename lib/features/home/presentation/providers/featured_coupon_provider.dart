import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for managing the persistent featured coupon
final featuredCouponManagerProvider = Provider((ref) => FeaturedCouponManager());

class FeaturedCouponManager {
  final _storage = const FlutterSecureStorage();
  static const _couponKey = 'pending_featured_coupon';

  /// Save the coupon code to persist across sessions
  Future<void> saveCoupon(String code) async {
    await _storage.write(key: _couponKey, value: code);
  }

  /// Get the saved coupon code
  Future<String?> getSavedCoupon() async {
    return await _storage.read(key: _couponKey);
  }

  /// Clear the saved coupon code
  Future<void> clearCoupon() async {
    await _storage.delete(key: _couponKey);
  }
}
