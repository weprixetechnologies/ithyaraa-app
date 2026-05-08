import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../controllers/search_controller.dart';

/// Provider for Dio instance for search API
final searchDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add logging interceptor with enhanced lifecycle tracking
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[DIO] REQUEST → ${options.method} ${options.path}');
        if (options.queryParameters.isNotEmpty) {
          debugPrint('[DIO] Query Parameters: ${options.queryParameters}');
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

/// Provider for search remote data source
final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  final dio = ref.read(searchDioProvider);
  return SearchRemoteDataSourceImpl(dio: dio);
});

/// Provider for search repository
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dataSource = ref.read(searchRemoteDataSourceProvider);
  return SearchRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for search products use case
final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  final repository = ref.read(searchRepositoryProvider);
  return SearchProductsUseCase(repository);
});

/// Provider for search controller
final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
      final useCase = ref.read(searchProductsUseCaseProvider);
      return SearchController(useCase);
    });
