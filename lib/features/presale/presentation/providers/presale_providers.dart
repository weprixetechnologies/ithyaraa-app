import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interceptors/token_refresh_interceptor.dart';
import '../../data/datasources/presale_remote_datasource.dart';
import '../../data/repositories/presale_repository_impl.dart';
import '../../domain/repositories/presale_repository.dart';

/// Provider for Dio instance for presale API
final presaleDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add auth interceptor to handle access tokens
  dio.interceptors.add(TokenRefreshInterceptor(ref));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[PRESALE DIO] REQUEST → ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '[PRESALE DIO] RESPONSE → ${response.requestOptions.path} (${response.statusCode})',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('[PRESALE DIO] ERROR → ${error.requestOptions.path}');
        handler.next(error);
      },
    ),
  );

  return dio;
});

/// Provider for presale remote data source
final presaleRemoteDataSourceProvider = Provider<PresaleRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(presaleDioProvider);
  return PresaleRemoteDataSourceImpl(dio: dio);
});

/// Provider for presale repository
final presaleRepositoryProvider = Provider<PresaleRepository>((ref) {
  final dataSource = ref.watch(presaleRemoteDataSourceProvider);
  return PresaleRepositoryImpl(remoteDataSource: dataSource);
});
