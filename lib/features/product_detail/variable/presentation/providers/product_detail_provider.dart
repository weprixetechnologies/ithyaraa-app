import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/product_detail_remote_datasource.dart';
import '../../data/repositories/product_detail_repository_impl.dart';
import '../../domain/repositories/product_detail_repository.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../controllers/product_detail_controller.dart';

/// Provider for Dio instance for product detail API
final productDetailDioProvider = Provider<Dio>((ref) {
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

/// Provider for product detail remote data source
final productDetailRemoteDataSourceProvider =
    Provider<ProductDetailRemoteDataSource>((ref) {
      final dio = ref.read(productDetailDioProvider);
      return ProductDetailRemoteDataSourceImpl(dio: dio);
    });

/// Provider for product detail repository
final productDetailRepositoryProvider = Provider<ProductDetailRepository>((
  ref,
) {
  final dataSource = ref.read(productDetailRemoteDataSourceProvider);
  return ProductDetailRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for get product detail use case
final getProductDetailUseCaseProvider = Provider<GetProductDetailUseCase>((
  ref,
) {
  final repository = ref.read(productDetailRepositoryProvider);
  return GetProductDetailUseCase(repository);
});

/// Provider for product detail controller (scoped by productID)
/// Uses autoDispose to automatically dispose state when widget is unmounted
final productDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<ProductDetailController, ProductDetailState, String>((
      ref,
      productID,
    ) {
      final useCase = ref.read(getProductDetailUseCaseProvider);
      return ProductDetailController(useCase, productID: productID);
    });
