import 'package:dio/dio.dart';
import '../../../../core/interceptors/token_refresh_interceptor.dart';

abstract class BuyNowRemoteDataSource {
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body);
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double subtotal,
    String? email,
    String? productID,
  });
  Future<Map<String, dynamic>> checkOffer({
    required String productID,
    required int quantity,
    required String productType,
    String? variationID,
  });
  Future<Map<String, dynamic>> getShippingFee({
    required String productID,
    required double subtotal,
  });
  Future<Map<String, dynamic>> checkPhone(String phone);
  Future<Map<String, dynamic>> sendOtp(String phoneNumber);
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp);
}

class BuyNowRemoteDataSourceImpl implements BuyNowRemoteDataSource {
  final Dio _dio;

  BuyNowRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        '/api/order/buy-now',
        data: {
          ...body,
          'device': 'app',
        },
        options: Options(
          extra: {AuthInterceptorExtra.requireAuth: false},
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double subtotal,
    String? email,
    String? productID,
  }) async {
    try {
      final response = await _dio.get(
        '/api/order/buy-now/validate-coupon',
        queryParameters: {
          'code': code,
          'subtotal': subtotal,
          if (email != null) 'email': email,
          if (productID != null) 'productID': productID,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> checkOffer({
    required String productID,
    required int quantity,
    required String productType,
    String? variationID,
  }) async {
    try {
      final response = await _dio.get(
        '/api/order/buy-now/check-offer',
        queryParameters: {
          'productID': productID,
          'quantity': quantity,
          'productType': productType,
          if (variationID != null) 'variationID': variationID,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getShippingFee({
    required String productID,
    required double subtotal,
  }) async {
    try {
      final response = await _dio.get(
        '/api/order/buy-now/shipping-fee',
        queryParameters: {
          'productID': productID,
          'subtotal': subtotal,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> checkPhone(String phone) async {
    final formattedPhone = phone.startsWith('+91') ? phone : '+91$phone';
    try {
      final response = await _dio.get(
        '/api/user/check-phone',
        queryParameters: {'phone': formattedPhone},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final formattedPhone = phoneNumber.startsWith('+91') ? phoneNumber : '+91$phoneNumber';
    try {
      final response = await _dio.post(
        '/api/user/send-otp',
        data: {'phoneNumber': formattedPhone},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final formattedPhone = phoneNumber.startsWith('+91') ? phoneNumber : '+91$phoneNumber';
    try {
      final response = await _dio.post(
        '/api/user/verify-otp',
        data: {'phoneNumber': formattedPhone, 'otp': otp},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final message = e.response!.data['message'] ?? e.response!.data['error'];
      if (message != null) return Exception(message);
    }
    return Exception(e.message ?? 'An unexpected error occurred');
  }
}
