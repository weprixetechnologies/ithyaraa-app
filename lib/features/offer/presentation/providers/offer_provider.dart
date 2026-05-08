import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/offer_remote_datasource.dart';
import '../../data/repositories/offer_repository_impl.dart';
import '../../domain/repositories/offer_repository.dart';
import '../../domain/entities/offer_filters.dart';
import '../../domain/usecases/get_all_offers_usecase.dart';
import '../controllers/offer_controller.dart';
import '../state/offer_state.dart';

/// Provider for Dio instance for offer API (public endpoint, no auth required)
final offerDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add logging interceptor
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
        handler.next(response);
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

/// Provider for offer remote data source
final offerRemoteDataSourceProvider = Provider<OfferRemoteDataSource>((ref) {
  final dio = ref.read(offerDioProvider);
  return OfferRemoteDataSourceImpl(dio: dio);
});

/// Provider for offer repository
final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  final dataSource = ref.read(offerRemoteDataSourceProvider);
  return OfferRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for get all offers use case
final getAllOffersUseCaseProvider = Provider<GetAllOffersUseCase>((ref) {
  final repository = ref.read(offerRepositoryProvider);
  return GetAllOffersUseCase(repository);
});

/// Provider family for offer controller
/// Each OfferListPage instance gets its own controller with its own filters
final offerControllerProvider =
    StateNotifierProvider.family<OfferController, OfferState, OfferFilters?>((
      ref,
      filters,
    ) {
      final useCase = ref.read(getAllOffersUseCaseProvider);
      return OfferController(useCase, initialFilters: filters);
    });
