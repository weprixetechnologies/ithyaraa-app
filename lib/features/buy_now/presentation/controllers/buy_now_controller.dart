import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ithyaraaapp/features/buy_now/data/datasources/buy_now_remote_datasource.dart';
import 'package:ithyaraaapp/features/buy_now/presentation/state/buy_now_state.dart';
import 'package:ithyaraaapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:ithyaraaapp/features/address/presentation/providers/address_providers.dart';
import 'package:ithyaraaapp/features/order/presentation/pages/order_detail_page.dart';

class BuyNowNotifier extends StateNotifier<BuyNowState> {
  final BuyNowRemoteDataSource _remoteDataSource;
  final Ref _ref;

  BuyNowNotifier(this._remoteDataSource, this._ref, BuyNowState initialState)
    : super(initialState) {
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    state = state.copyWith(isLoading: true);
    final authState = _ref.read(authProvider);

    try {
      await Future.wait([_checkOffer(), _getShippingFee()]);

      if (authState.isLoggedIn) {
        Future.microtask(() async {
          try {
            await _ref.read(addressControllerProvider.notifier).loadAddresses();
            if (!mounted) return;

            final addressState = _ref.read(addressControllerProvider);
            if (state.selectedAddressID == null &&
                addressState.addresses.isNotEmpty) {
              final firstAddr = addressState.addresses.first;
              state = state.copyWith(selectedAddressID: firstAddr.addressID);
            }
          } catch (e) {
            debugPrint('[BuyNow] Error loading addresses in background: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('[BuyNow] Error fetching initial buy-now data: $e');
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> _checkOffer() async {
    if (state.productType == 'customproduct' ||
        state.productType == 'make_combo') {
      return;
    }

    try {
      final response = await _remoteDataSource.checkOffer(
        productID: state.productID,
        quantity: state.quantity,
        productType: state.productType,
        variationID: state.variationID,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          offerSavedAmount:
              (response['savedAmount'] as num?)?.toDouble() ?? 0.0,
          freeUnits: (response['freeUnits'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (e) {
      debugPrint('Check offer failed: $e');
    }
  }

  Future<void> _getShippingFee() async {
    try {
      final response = await _remoteDataSource.getShippingFee(
        productID: state.productID,
        subtotal: state.subtotal,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          shippingFee: (response['shippingFee'] as num?)?.toDouble() ?? 0.0,
        );
      }
    } catch (e) {
      debugPrint('Get shipping fee failed: $e');
    }
  }

  void updateQuantity(int newQuantity) {
    if (newQuantity < 1) return;
    state = state.copyWith(quantity: newQuantity);
    _checkOffer();
    _getShippingFee();
  }

  void setAddress(String addressID) {
    state = state.copyWith(
      selectedAddressID: addressID,
      isAddingNewAddress: false,
    );
  }

  void setPaymentMode(String mode) {
    state = state.copyWith(paymentMode: mode);
  }

  void updateNewAddressData(Map<String, dynamic> addressData) {
    state = state.copyWith(newAddressData: addressData);
  }

  void updateGuestInfo({String? name, String? email, String? phone}) {
    state = state.copyWith(
      guestName: name ?? state.guestName,
      guestEmail: email ?? state.guestEmail,
      guestPhone: phone ?? state.guestPhone,
    );
  }

  void updateOtpCode(String code) {
    state = state.copyWith(otpCode: code);
  }

  Future<void> applyCoupon(String code) async {
    if (code.isEmpty) return;

    state = state.copyWith(isLoading: true, couponError: null);
    try {
      final response = await _remoteDataSource.validateCoupon(
        code: code,
        subtotal: state.subtotal,
        email: state.guestEmail.isNotEmpty ? state.guestEmail : null,
        productID: state.productID,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          couponCode: code,
          couponDiscount: _parsePrice(response['couponDiscount']),
          shippingFee: _parsePrice(
            response['shippingFee'],
            defaultValue: state.shippingFee,
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          couponError: response['message'] ?? 'Invalid coupon',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(couponError: e.toString(), isLoading: false);
    }
  }

  double _parsePrice(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  void removeCoupon() {
    state = state.copyWith(
      couponCode: '',
      couponDiscount: 0.0,
      couponError: null,
    );
  }

  /// Entry point for "Confirm Order" or "Pay Now" button
  Future<void> handleOrderAction(BuildContext context) async {
    final authState = _ref.read(authProvider);
    final addressState = _ref.read(addressControllerProvider);

    if (authState.isLoggedIn) {
      if (state.selectedAddressID == null &&
          addressState.addresses.isNotEmpty) {
        final firstAddr = addressState.addresses.first;
        state = state.copyWith(selectedAddressID: firstAddr.addressID);
      }

      if (state.selectedAddressID == null &&
          (state.newAddressData == null || state.newAddressData!.isEmpty)) {
        state = state.copyWith(
          error: 'Please select a delivery address or add a new one',
        );
        return;
      }
    } else {
      if (state.guestName.isEmpty ||
          state.guestEmail.isEmpty ||
          state.guestPhone.isEmpty) {
        state = state.copyWith(error: 'Please fill all guest details');
        return;
      }
      if (state.newAddressData == null || state.newAddressData!.isEmpty) {
        state = state.copyWith(error: 'Please provide a shipping address');
        return;
      }
    }

    if (!context.mounted) return;
    if (authState.isLoggedIn) {
      await _actualPlaceOrder(context);
    } else {
      await _checkPhoneAndProceed(context);
    }
  }

  Future<void> _checkPhoneAndProceed(BuildContext context) async {
    state = state.copyWith(isCheckingPhone: true, error: null);
    try {
      final res = await _remoteDataSource.checkPhone(state.guestPhone);

      if (res['exists'] == true) {
        if (!context.mounted) {
          state = state.copyWith(isCheckingPhone: false);
          return;
        }
        state = state.copyWith(isCheckingPhone: false);
        await _actualPlaceOrder(context);
      } else {
        await _remoteDataSource.sendOtp(state.guestPhone);
        if (!context.mounted) {
          state = state.copyWith(isCheckingPhone: false);
          return;
        }
        state = state.copyWith(
          step: BuyNowStep.otp,
          otpRequired: true,
          isCheckingPhone: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isCheckingPhone: false, error: e.toString());
    }
  }

  Future<void> verifyOtpAndPlaceOrder(BuildContext context) async {
    if (state.otpCode.length < 6) {
      state = state.copyWith(error: 'Please enter a valid 6-digit OTP');
      return;
    }

    state = state.copyWith(isVerifyingOtp: true, error: null);
    try {
      final res = await _remoteDataSource.verifyOtp(
        state.guestPhone,
        state.otpCode,
      );
      if (res['success'] == true) {
        if (!context.mounted) return;
        state = state.copyWith(isVerifyingOtp: false);
        await _actualPlaceOrder(context);
      } else {
        state = state.copyWith(
          isVerifyingOtp: false,
          error: res['message'] ?? 'OTP verification failed',
        );
      }
    } catch (e) {
      state = state.copyWith(isVerifyingOtp: false, error: e.toString());
    }
  }

  Future<void> _actualPlaceOrder(BuildContext context) async {
    final authState = _ref.read(authProvider);
    state = state.copyWith(
      isPlacingOrder: true,
      isCheckingPhone: false,
      error: null,
    );

    try {
      final body = <String, dynamic>{
        'productType': state.productType,
        'productID': state.productID,
        'quantity': state.quantity,
        'variationID': state.variationID,
        'selectedItems': state.selectedItems ?? [],
        'customInputs': state.customInputs ?? {},
        'selectedDressType': state.selectedDressType,
        'couponCode': state.couponCode,
        'paymentMode': state.paymentMode,
      };

      if (authState.isLoggedIn) {
        if (state.selectedAddressID != null) {
          body['existingAddressID'] = state.selectedAddressID;
        } else {
          body['address'] = state.newAddressData;
        }
      } else {
        body['guestDetails'] = {
          'name': state.guestName,
          'email': state.guestEmail,
          'phone': state.guestPhone,
        };
        body['address'] = state.newAddressData;
        if (state.otpRequired) {
          body['otp'] = state.otpCode;
          body['phoneVerified'] = true;
        }
      }

      final response = await _remoteDataSource.placeOrder(body);

      if (response['success'] == true) {
        final orderID = response['orderID'];
        final sessionToken = response['sessionToken'];
        final isNewUser = response['isNewUser'] == true;

        if (isNewUser && sessionToken != null) {
          await _ref
              .read(authProvider.notifier)
              .loginWithSessionToken(sessionToken);
        }

        if (!context.mounted) {
          state = state.copyWith(isPlacingOrder: false);
          return;
        }

        if (state.paymentMode == 'COD') {
          state = state.copyWith(isPlacingOrder: false);
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailPage(orderID: orderID.toString()),
            ),
          );
        } else if (state.paymentMode == 'PREPAID') {
          state = state.copyWith(isPlacingOrder: false);
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailPage(orderID: orderID.toString()),
            ),
          );

          final flow = response['flow'] as String?;
          debugPrint('[Payment] Flow: $flow');

          if (flow == 'TOKEN') {
            final payUrl = response['payUrl'] as String?;
            debugPrint('[Payment] Pay URL: $payUrl');

            if (payUrl != null && payUrl.trim().isNotEmpty) {
              final uri = Uri.tryParse(payUrl.trim());
              if (uri != null && uri.hasScheme && uri.hasAuthority) {
                launchUrl(uri, mode: LaunchMode.externalApplication).catchError(
                  (e) {
                    debugPrint('[Payment] Launch Error: $e');
                    state = state.copyWith(
                      error: 'Unable to start payment. Please try again.',
                    );
                    return true;
                  },
                );
              } else {
                state = state.copyWith(
                  error: 'Unable to start payment. Please try again.',
                );
              }
            } else {
              state = state.copyWith(
                error: 'Unable to start payment. Please try again.',
              );
            }
          } else {
            // Existing logic for other flows (e.g., PAY_PAGE)
            final rawUrl =
                (response['phonePeRedirectURL'] ?? response['url'])
                    as String? ??
                '';
            if (rawUrl.isNotEmpty) {
              final uri = Uri.tryParse(rawUrl.trim());
              if (uri != null && uri.hasScheme && uri.hasAuthority) {
                launchUrl(uri, mode: LaunchMode.inAppBrowserView).catchError((
                  e,
                ) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                  return true;
                });
              }
            }
          }
        }
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Failed to place order',
          isPlacingOrder: false,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isPlacingOrder: false);
    }
  }

  void resendOtp() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _remoteDataSource.sendOtp(state.guestPhone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void backToDetails() {
    state = state.copyWith(
      step: BuyNowStep.details,
      error: null,
      isCheckingPhone: false,
      isVerifyingOtp: false,
      isLoading: false,
      isPlacingOrder: false,
    );
  }
}
