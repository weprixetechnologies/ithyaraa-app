import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/shop_remote_datasource.dart';
import '../../data/repositories/shop_repository_impl.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../domain/entities/shop_filters.dart';
import '../../domain/usecases/get_shop_products_usecase.dart';
import '../controllers/shop_controller.dart';

/// Provider for Dio instance for shop API
final shopDioProvider = Provider<Dio>((ref) {
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

/// Provider for shop remote data source
final shopRemoteDataSourceProvider = Provider<ShopRemoteDataSource>((ref) {
  final dio = ref.read(shopDioProvider);
  return ShopRemoteDataSourceImpl(dio: dio);
});

/// Provider for shop repository
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final dataSource = ref.read(shopRemoteDataSourceProvider);
  return ShopRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for get shop products use case
final getShopProductsUseCaseProvider = Provider<GetShopProductsUseCase>((ref) {
  final repository = ref.read(shopRepositoryProvider);
  return GetShopProductsUseCase(repository);
});

/// Provider family for route-scoped shop controller
/// Each ShopPage instance gets its own controller with its own filters
final shopControllerProvider =
    StateNotifierProvider.family<ShopController, ShopState, ShopFilters?>((
      ref,
      filters,
    ) {
      final useCase = ref.read(getShopProductsUseCaseProvider);
      return ShopController(useCase, initialFilters: filters);
    });
