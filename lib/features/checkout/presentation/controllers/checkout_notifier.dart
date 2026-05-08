import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../order/domain/usecases/place_order_usecase.dart';
import '../../../order/domain/usecases/apply_coupon_usecase.dart';
import '../../../order/presentation/pages/order_confirmation_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/presentation/providers/featured_coupon_provider.dart';
import '../state/checkout_state.dart';

/// Checkout notifier managing checkout flow state
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final PlaceOrderUseCase placeOrderUseCase;
  final ApplyCouponUseCase applyCouponUseCase;
  final Ref ref;

  CheckoutNotifier({
    required this.placeOrderUseCase,
    required this.applyCouponUseCase,
    required this.ref,
  }) : super(CheckoutState());

  /// Set selected address ID
  void setAddress(String addressID) {
    state = state.copyWith(selectedAddressID: addressID);
  }

  /// Set payment mode
  void setPaymentMode(String mode) {
    state = state.copyWith(paymentMode: mode);
  }

  /// Set wallet applied amount
  void setWalletApplied(double amount) {
    state = state.copyWith(walletApplied: amount);
  }

  /// Apply coupon code
  Future<void> applyCoupon(String couponCode, {int? cartID}) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final response = await applyCouponUseCase(
        couponCode: couponCode,
        cartID: cartID,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          loading: false,
          couponCode: couponCode,
          couponResponse: response,
        );
        // Clear featured coupon from storage once a coupon is applied
        ref.read(featuredCouponManagerProvider).clearCoupon();
      } else {
        state = state.copyWith(
          loading: false,
          error: response['message'] as String? ?? 'Failed to apply coupon',
          clearCoupon: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
        clearCoupon: true,
      );
    }
  }

  /// Remove applied coupon
  void removeCoupon() {
    state = state.copyWith(
      clearCoupon: true,
    );
    // Also clear the persistent featured coupon so it doesn't re-apply
    ref.read(featuredCouponManagerProvider).clearCoupon();
  }

  /// Extract PhonePe checkout URL from response
  String extractCheckoutUrl(Map<String, dynamic> response) {
    final checkoutPageUrl = response['checkoutPageUrl'];

    // Preferred contract: plain non-empty string URL
    if (checkoutPageUrl is String) {
      final trimmed = checkoutPageUrl.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
      throw Exception('Missing checkoutPageUrl in response');
    }

    // Backward-compatible: nested structure from older PhonePe responses
    if (checkoutPageUrl is Map<String, dynamic>) {
      final data = checkoutPageUrl['data'];
      if (data is Map<String, dynamic>) {
        final instrumentResponse = data['instrumentResponse'];
        if (instrumentResponse is Map<String, dynamic>) {
          final redirectInfo = instrumentResponse['redirectInfo'];
          if (redirectInfo is Map<String, dynamic>) {
            final url = redirectInfo['url'];
            if (url is String) {
              return url;
            }
          }
        }
      }
    }

    throw Exception('Invalid checkout URL format in response');
  }

  /// Place order
  Future<void> placeOrder(BuildContext context) async {
    if (state.loading) return;

    if (state.selectedAddressID == null || state.selectedAddressID!.isEmpty) {
      state = state.copyWith(error: 'Please select a delivery address');
      return;
    }

    final cartState = ref.read(cartControllerProvider).cartState;
    if (cartState == null || cartState.items.isEmpty) {
      state = state.copyWith(error: 'Cart is empty');
      return;
    }

    final selectedItems = cartState.items.where((item) => item.isSelected).toList();
    if (selectedItems.isEmpty) {
      state = state.copyWith(error: 'No selected items in cart.');
      return;
    }

    state = state.copyWith(loading: true, error: null);

    try {
      final body = <String, dynamic>{
        'addressID': state.selectedAddressID,
        'paymentMode': state.paymentMode,
        // device: app is kept for backend tracking if useful, or removed if strictly revert.
        // I'll remove it to be strictly original.
        if (state.couponCode != null && state.couponCode!.isNotEmpty)
          'couponCode': state.couponCode,
        if (state.walletApplied > 0) 'walletApplied': state.walletApplied,
      };

      final response = await placeOrderUseCase(body);

      if (response['success'] != true) {
        final err = (response['error'] ?? response['message']) as String?;
        state = state.copyWith(loading: false, error: err ?? 'Failed to place order');
        return;
      }

      final orderID = response['orderID'];
      final rawPaymentMode = response['paymentMode'] as String?;
      final paymentMode = rawPaymentMode?.toUpperCase() ?? 'COD';

      if (!context.mounted) {
        state = state.copyWith(loading: false);
        return;
      }

      if (paymentMode == 'COD' || paymentMode == 'FULL_COIN') {
        state = state.copyWith(loading: false);
        ref.read(cartControllerProvider.notifier).loadCart();
        ref.read(featuredCouponManagerProvider).clearCoupon(); // Clear used coupon
        
        if (orderID != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OrderConfirmationPage(orderID: orderID.toString())),
          );
        }
      } else if (paymentMode == 'PREPAID') {
        state = state.copyWith(loading: false);
        ref.read(featuredCouponManagerProvider).clearCoupon(); // Clear used coupon

        if (orderID != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderConfirmationPage(orderID: orderID.toString()),
            ),
          );
        }

        final flow = response['flow'] as String?;
        debugPrint('[Payment] Flow: $flow');

        if (flow == 'TOKEN') {
          final payUrl = response['payUrl'] as String?;
          debugPrint('[Payment] Pay URL: $payUrl');

          if (payUrl != null && payUrl.trim().isNotEmpty) {
            final uri = Uri.tryParse(payUrl.trim());
            if (uri != null && uri.hasScheme && uri.hasAuthority) {
              launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
                debugPrint('[Payment] Launch Error: $e');
                state = state.copyWith(error: 'Unable to start payment. Please try again.');
                return true;
              });
            } else {
              state = state.copyWith(error: 'Unable to start payment. Please try again.');
            }
          } else {
            state = state.copyWith(error: 'Unable to start payment. Please try again.');
          }
        } else {
          // Existing logic for other flows (e.g., PAY_PAGE)
          final rawUrl =
              (response['phonePeRedirectURL'] ??
                  response['url'] ??
                  extractCheckoutUrl(response)) as String? ??
              '';
          if (rawUrl.isNotEmpty) {
            final uri = Uri.tryParse(rawUrl.trim());
            if (uri != null && uri.hasScheme && uri.hasAuthority) {
              dev.log('[Payment] Opening Web URL: $uri', name: 'Payment');
              launchUrl(uri, mode: LaunchMode.inAppBrowserView).catchError((e) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
                return true;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[Checkout] Error in placeOrder: $e');
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
