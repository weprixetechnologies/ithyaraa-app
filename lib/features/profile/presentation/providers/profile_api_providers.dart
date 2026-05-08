import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interceptors/token_refresh_interceptor.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/send_verification_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

/// Provider for Dio instance for profile API with token refresh interceptor
final profileDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add safe auth interceptor (pass-through only, no refresh logic)
  dio.interceptors.add(TokenRefreshInterceptor(ref));

  // Add logging interceptor with enhanced lifecycle tracking
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[DIO] REQUEST → ${options.method} ${options.path}');
        if (options.data != null) {
          debugPrint('[DIO] Request Body: ${options.data}');
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

  return dio;
});

/// Provider for profile remote data source
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  final dio = ref.read(profileDioProvider);
  return ProfileRemoteDataSourceImpl(dio: dio);
});

/// Provider for profile repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.read(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for get profile use case
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return GetProfileUseCase(repository);
});

/// Provider for update profile use case
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

/// Provider for send verification OTP use case
final sendVerificationOtpUseCaseProvider = Provider<SendVerificationOtpUseCase>(
  (ref) {
    final repository = ref.read(profileRepositoryProvider);
    return SendVerificationOtpUseCase(repository);
  },
);

/// Provider for verify OTP use case
final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return VerifyOtpUseCase(repository);
});
