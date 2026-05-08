import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/interceptors/token_refresh_interceptor.dart';
import '../../../../core/errors/session_expired_exception.dart';
import '../models/add_to_cart_response_model.dart';
import '../models/cart_state_model.dart';

AddToCartResponseModel _parseAddToCartResponse(Map<String, dynamic> data) {
  return AddToCartResponseModel.fromJson(data);
}

CartStateModel _parseCartStateResponse(Map<String, dynamic> data) {
  return CartStateModel.fromJson(data);
}

/// Remote data source for cart API
abstract class CartRemoteDataSource {
  Future<AddToCartResponseModel> addToCart({
    required String productID,
    required int quantity,
    String? variationID,
    String? variationName,
    String? referBy,
    Map<String, dynamic>? customInputs,
    Map<String, dynamic>? selectedDressType,
  });

  /// Add combo product to cart
  Future<AddToCartResponseModel> addComboToCart({
    required String mainProductID,
    required int quantity,
    required List<Map<String, String>> products, // [{productID, variationID}]
  });

  Future<CartStateModel> getCart();

  Future<void> removeCartItem({required String cartItemID});

  Future<CartStateModel> updateCartSelection({
    required List<String> selectedItems,
  });

  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    int? cartID,
  });
  
  Future<void> autoUpdateCartSelection();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl({required this.dio});

  @override
  Future<AddToCartResponseModel> addToCart({
    required String productID,
    required int quantity,
    String? variationID,
    String? variationName,
    String? referBy,
    Map<String, dynamic>? customInputs,
    Map<String, dynamic>? selectedDressType,
  }) async {
    try {
      final payload = <String, dynamic>{
        'productID': productID,
        'quantity': quantity,
      };
      if (variationID != null) payload['variationID'] = variationID;
      if (variationName != null) payload['variationName'] = variationName;
      if (referBy != null) payload['referBy'] = referBy;
      if (customInputs != null) payload['customInputs'] = customInputs;
      if (selectedDressType != null) {
        payload['selectedDressType'] = selectedDressType;
      }

      final response = await dio.post(
        '/api/cart/add-cart',
        data: payload,
        options: Options(extra: {AuthInterceptorExtra.requireAuth: true}),
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return await compute(_parseAddToCartResponse, responseData);
      } else {
        throw Exception(
          responseData['message'] as String? ?? 'Failed to add item to cart',
        );
      }
    } on DioException catch (e) {
      if (e.requestOptions.extra[AuthInterceptorExtra.sessionExpired] == true) {
        throw SessionExpiredException(_extractErrorMessage(e));
      }
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CartStateModel> getCart() async {
    try {
      final response = await dio.post('/api/cart/get-cart');

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return await compute(_parseCartStateResponse, responseData);
      } else {
        throw Exception(
          responseData['message'] as String? ?? 'Failed to get cart',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeCartItem({required String cartItemID}) async {
    try {
      final response = await dio.post(
        '/api/cart/remove-cart',
        data: {'cartItemID': cartItemID},
      );

      // Check for success via response data or HTTP status
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['success'] != true) {
          throw Exception(
            responseData['message'] as String? ??
                'Failed to remove item from cart',
          );
        }
      }
      // If response is not a map, rely on HTTP status code (200/204 = success)
      // Dio will throw DioException for non-2xx status codes, so reaching here means success
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CartStateModel> updateCartSelection({
    required List<String> selectedItems,
  }) async {
    try {
      final response = await dio.post(
        '/api/cart/update-cart-selected',
        data: {'selectedItems': selectedItems},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        final cartJson = responseData['cart'] as Map<String, dynamic>;
        return await compute(_parseCartStateResponse, cartJson);
      } else {
        throw Exception(
          responseData['message'] as String? ??
              'Failed to update cart selection',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AddToCartResponseModel> addComboToCart({
    required String mainProductID,
    required int quantity,
    required List<Map<String, String>> products,
  }) async {
    try {
      final payload = <String, dynamic>{
        'mainProductID': mainProductID,
        'quantity': quantity,
        'products': products,
      };

      final response = await dio.post(
        '/api/cart/add-cart-combo',
        data: payload,
        options: Options(extra: {AuthInterceptorExtra.requireAuth: true}),
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return await compute(_parseAddToCartResponse, responseData);
      } else {
        throw Exception(
          responseData['message'] as String? ?? 'Failed to add combo to cart',
        );
      }
    } on DioException catch (e) {
      if (e.requestOptions.extra[AuthInterceptorExtra.sessionExpired] == true) {
        throw SessionExpiredException(_extractErrorMessage(e));
      }
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    int? cartID,
  }) async {
    try {
      final body = <String, dynamic>{
        'couponCode': couponCode,
        if (cartID != null) 'cartID': cartID,
      };

      final response = await dio.post(
        '/api/user-coupon/apply-coupon',
        data: body,
        options: Options(extra: {AuthInterceptorExtra.requireAuth: true}),
      );

      final responseData = response.data as Map<String, dynamic>;
      return responseData;
    } on DioException catch (e) {
      if (e.requestOptions.extra[AuthInterceptorExtra.sessionExpired] == true) {
        throw SessionExpiredException(_extractErrorMessage(e));
      }
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> autoUpdateCartSelection() async {
    try {
      final response = await dio.post(
        '/api/cart/auto-update-selection',
        options: Options(extra: {AuthInterceptorExtra.requireAuth: true}),
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(
          responseData['message'] as String? ?? 'Failed to update cart selection',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Unauthorized. Please login again.';
        case 404:
          return 'Cart not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed with status $statusCode';
      }
    }

    return e.message ?? 'An unexpected error occurred';
  }
}
