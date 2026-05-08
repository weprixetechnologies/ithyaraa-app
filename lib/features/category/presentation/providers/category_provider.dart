import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';
import '../controllers/category_controller.dart';

/// Provider for Dio instance for category API (reuse shop Dio config)
final categoryDioProvider = Provider<Dio>((ref) {
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

/// Provider for category remote data source
final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  final dio = ref.read(categoryDioProvider);
  return CategoryRemoteDataSourceImpl(dio: dio);
});

/// Provider for category repository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.read(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for get all categories use case
final getAllCategoriesUseCaseProvider = Provider<GetAllCategoriesUseCase>((
  ref,
) {
  final repository = ref.read(categoryRepositoryProvider);
  return GetAllCategoriesUseCase(repository);
});

/// Provider for category controller
final categoryControllerProvider =
    StateNotifierProvider<CategoryController, CategoryState>((ref) {
      final useCase = ref.read(getAllCategoriesUseCaseProvider);
      return CategoryController(useCase);
    });
