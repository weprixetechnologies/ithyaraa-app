import 'package:dio/dio.dart';
import '../models/profile_model.dart';
import '../models/coin_balance_model.dart';
import '../models/coin_history_model.dart';
import '../models/locked_coins_model.dart';
import '../models/return_history_model.dart';
import 'package:flutter/foundation.dart';

/// Remote data source for profile API
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfileDetails();
  Future<ProfileModel> updateProfile({String? name, String? profilePhoto});
  Future<void> sendVerificationOtp(String identifier);
  Future<void> verifyOtp(String identifier, String otp);

  // Coins
  Future<CoinBalanceModel> getCoinBalance();
  Future<CoinHistoryResponse> getCoinHistory(int page);
  Future<LockedCoinsResponse> getLockedCoinsBreakdown();
  Future<void> redeemCoins(int coins);

  // Returns
  Future<ReturnHistoryResponse> getReturnHistory();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProfileModel> getProfileDetails() async {
    debugPrint('[PROFILE DATA SOURCE] Fetching profile details');

    try {
      final response = await dio.get('/api/user/detail-by-user');

      debugPrint('[PROFILE DATA SOURCE] Response received successfully');
      final profile = ProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      debugPrint('[PROFILE DATA SOURCE] Profile loaded: ${profile.username}');

      return profile;
    } on DioException catch (e) {
      debugPrint('[PROFILE DATA SOURCE] Error occurred: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '[PROFILE DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[PROFILE DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint(
        '[PROFILE DATA SOURCE] Extracted error message: $errorMessage',
      );
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[PROFILE DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? name,
    String? profilePhoto,
  }) async {
    debugPrint('[PROFILE DATA SOURCE] Updating profile');

    try {
      final body = <String, dynamic>{};
      if (name != null && name.isNotEmpty) {
        body['name'] = name;
      }
      if (profilePhoto != null && profilePhoto.isNotEmpty) {
        body['profilePhoto'] = profilePhoto;
      }

      if (body.isEmpty) {
        throw Exception('No fields to update');
      }

      final response = await dio.put('/api/user/update-by-user', data: body);

      debugPrint('[PROFILE DATA SOURCE] Profile updated successfully');

      // Response contains updated user data
      final responseData = response.data as Map<String, dynamic>;
      final userData =
          responseData['user'] as Map<String, dynamic>? ?? responseData;

      final profile = ProfileModel.fromJson(userData);
      debugPrint('[PROFILE DATA SOURCE] Updated profile: ${profile.username}');

      return profile;
    } on DioException catch (e) {
      debugPrint('[PROFILE DATA SOURCE] Error occurred: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '[PROFILE DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[PROFILE DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint(
        '[PROFILE DATA SOURCE] Extracted error message: $errorMessage',
      );
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[PROFILE DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendVerificationOtp(String identifier) async {
    debugPrint(
      '[PROFILE DATA SOURCE] Sending verification OTP to: $identifier',
    );

    try {
      final response = await dio.post(
        '/api/user/forgot-password',
        data: {'identifier': identifier},
      );

      debugPrint('[PROFILE DATA SOURCE] OTP sent successfully');

      final responseData = response.data as Map<String, dynamic>;
      final success = responseData['success'] as bool?;
      if (success != true) {
        throw Exception(
          responseData['message'] as String? ?? 'Failed to send OTP',
        );
      }
    } on DioException catch (e) {
      debugPrint('[PROFILE DATA SOURCE] Error sending OTP: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '[PROFILE DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[PROFILE DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint(
        '[PROFILE DATA SOURCE] Extracted error message: $errorMessage',
      );
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[PROFILE DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyOtp(String identifier, String otp) async {
    debugPrint('[PROFILE DATA SOURCE] Verifying OTP for: $identifier');

    try {
      final response = await dio.post(
        '/api/user/verify-otp-reset-password',
        data: {'identifier': identifier, 'otp': otp},
      );

      debugPrint('[PROFILE DATA SOURCE] OTP verified successfully');

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] as String?;
      if (message == null || !message.toLowerCase().contains('success')) {
        throw Exception(
          responseData['message'] as String? ?? 'OTP verification failed',
        );
      }
    } on DioException catch (e) {
      debugPrint('[PROFILE DATA SOURCE] Error verifying OTP: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '[PROFILE DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[PROFILE DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint(
        '[PROFILE DATA SOURCE] Extracted error message: $errorMessage',
      );
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[PROFILE DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<CoinBalanceModel> getCoinBalance() async {
    debugPrint('[PROFILE DATA SOURCE] Fetching coin balance');
    try {
      final response = await dio.get('/api/coins/balance');
      return CoinBalanceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<CoinHistoryResponse> getCoinHistory(int page) async {
    debugPrint('[PROFILE DATA SOURCE] Fetching coin history - Page: $page');
    try {
      final response = await dio.get(
        '/api/coins/history',
        queryParameters: {'page': page, 'limit': 20},
      );
      return CoinHistoryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<LockedCoinsResponse> getLockedCoinsBreakdown() async {
    debugPrint('[PROFILE DATA SOURCE] Fetching locked coins breakdown');
    try {
      final response = await dio.get('/api/coins/locked-breakdown');
      return LockedCoinsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> redeemCoins(int coins) async {
    debugPrint('[PROFILE DATA SOURCE] Redeeming $coins coins');
    try {
      await dio.post('/api/coins/redeem', data: {'coins': coins});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<ReturnHistoryResponse> getReturnHistory() async {
    debugPrint('[PROFILE DATA SOURCE] Fetching return history');
    try {
      final response = await dio.get('/api/order/my-returns');
      return ReturnHistoryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
            data['error'] as String? ??
            e.message ??
            'An unexpected error occurred';
      }
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
