import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interceptors/token_refresh_interceptor.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/get_order_detail_usecase.dart';
import '../../domain/usecases/get_order_history_usecase.dart';
import '../../domain/usecases/send_invoice_email_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../domain/usecases/apply_coupon_usecase.dart';
import '../../domain/usecases/return_order_usecase.dart';

/// Provider for Dio instance for order API with token refresh interceptor
final orderDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add authenticated interceptor (handles token attachment and refresh)
  dio.interceptors.add(TokenRefreshInterceptor(ref));

  // Add logging interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[ORDER DIO] REQUEST → ${options.method} ${options.path}');
        if (options.queryParameters.isNotEmpty) {
          debugPrint(
            '[ORDER DIO] Query Parameters: ${options.queryParameters}',
          );
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '[ORDER DIO] RESPONSE → ${response.requestOptions.path} (${response.statusCode})',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('[ORDER DIO] ERROR → ${error.requestOptions.path}');
        debugPrint('[ORDER DIO] Error: ${error.message}');
        if (error.response != null) {
          debugPrint('[ORDER DIO] Error Status: ${error.response?.statusCode}');
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

/// Provider for order remote data source
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final dio = ref.read(orderDioProvider);
  return OrderRemoteDataSourceImpl(dio: dio);
});

/// Provider for order repository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dataSource = ref.read(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for get order history use case
final getOrderHistoryUseCaseProvider = Provider<GetOrderHistoryUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetOrderHistoryUseCase(repository);
});

/// Provider for get order detail use case
final getOrderDetailUseCaseProvider = Provider<GetOrderDetailUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetOrderDetailUseCase(repository);
});

/// Provider for send invoice email use case
final sendInvoiceEmailUseCaseProvider = Provider<SendInvoiceEmailUseCase>((
  ref,
) {
  final repository = ref.read(orderRepositoryProvider);
  return SendInvoiceEmailUseCase(repository);
});

/// Provider for place order use case
final placeOrderUseCaseProvider = Provider<PlaceOrderUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return PlaceOrderUseCase(repository);
});

/// Provider for apply coupon use case
final applyCouponUseCaseProvider = Provider<ApplyCouponUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return ApplyCouponUseCase(repository);
});

/// Provider for return order use case
final returnOrderUseCaseProvider = Provider<ReturnOrderUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return ReturnOrderUseCase(repository: repository);
});
