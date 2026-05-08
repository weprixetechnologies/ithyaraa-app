import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/combo_detail_remote_datasource.dart';
import '../../data/repositories/combo_detail_repository_impl.dart';
import '../../domain/repositories/combo_detail_repository.dart';
import '../../domain/usecases/get_combo_detail_usecase.dart';
import '../controllers/combo_detail_controller.dart';

/// Provider for Dio instance for combo detail API
final comboDetailDioProvider = Provider<Dio>((ref) {
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

/// Provider for combo detail remote data source
final comboDetailRemoteDataSourceProvider =
    Provider<ComboDetailRemoteDataSource>((ref) {
      final dio = ref.read(comboDetailDioProvider);
      return ComboDetailRemoteDataSourceImpl(dio: dio);
    });

/// Provider for combo detail repository
final comboDetailRepositoryProvider = Provider<ComboDetailRepository>((ref) {
  final dataSource = ref.read(comboDetailRemoteDataSourceProvider);
  return ComboDetailRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for get combo detail use case
final getComboDetailUseCaseProvider = Provider<GetComboDetailUseCase>((ref) {
  final repository = ref.read(comboDetailRepositoryProvider);
  return GetComboDetailUseCase(repository);
});

/// Provider for combo detail controller (scoped by productID)
/// Uses autoDispose to automatically dispose state when widget is unmounted
final comboDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<ComboDetailController, ComboDetailState, String>((ref, productID) {
      final useCase = ref.read(getComboDetailUseCaseProvider);
      return ComboDetailController(useCase, productID: productID);
    });
