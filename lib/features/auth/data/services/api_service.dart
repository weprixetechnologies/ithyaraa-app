import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;
  late final Dio _dio;

  ApiService({this.baseUrl = 'https://backend.ithyaraa.com'}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add logging interceptor with enhanced lifecycle tracking
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('[DIO] REQUEST → ${options.method} ${options.path}');
          if (options.data != null) {
            final data = options.data;
            if (data is Map<String, dynamic>) {
              // Mask password and confirmPassword in logs
              final logData = Map<String, dynamic>.from(data);
              if (logData.containsKey('password')) {
                logData['password'] = '***MASKED***';
              }
              if (logData.containsKey('confirmPassword')) {
                logData['confirmPassword'] = '***MASKED***';
              }
              debugPrint('[DIO] Request Body: $logData');
            } else {
              debugPrint('[DIO] Request Body: $data');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '[DIO] RESPONSE → ${response.requestOptions.path} (${response.statusCode})',
          );
          debugPrint('[DIO] Response received, calling handler.next()');
          handler.next(response);
          debugPrint(
            '[DIO] handler.next() completed for ${response.requestOptions.path}',
          );
        },
        onError: (error, handler) {
          debugPrint('[DIO] ERROR → ${error.requestOptions.path}');
          debugPrint('[DIO] Error: ${error.message}');
          if (error.response != null) {
            debugPrint('[DIO] Error Status: ${error.response?.statusCode}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/api/user/send-otp',
        data: {'phoneNumber': phoneNumber},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        '/api/user/verify-otp',
        data: {'phoneNumber': phoneNumber, 'otp': otp},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String phonenumber,
    required String email,
    required String password,
    required String confirmPassword,
    String? referCode,
  }) async {
    try {
      final data = {
        'password': password,
        'confirmPassword': confirmPassword,
        'name': name,
        'email': email,
        'phonenumber': phonenumber,
        'phoneVerified': true,
        if (referCode != null && referCode.isNotEmpty) 'referCode': referCode,
      };

      final response = await _dio.post('/api/user/create-user', data: data);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> login(
    String phonenumber,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/api/user/login',
        data: {'phonenumber': phonenumber, 'password': password},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Don't throw generic exception for 401/404 on refresh, let caller handle
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        throw e;
      }
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  /// Extracts user-friendly error message from DioException
  String _extractErrorMessage(DioException e) {
    // Try to extract message from response body
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final error = data['error'] as String?;
        if (error != null && error.isNotEmpty) {
          return error;
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }

    // Fallback to status code based messages
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Invalid credentials. Please try again.';
        case 409:
          return 'User already exists. Please sign in instead.';
        case 404:
          return 'Resource not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed with status $statusCode';
      }
    }

    // Final fallback
    return e.message ?? 'An unexpected error occurred';
  }
}
