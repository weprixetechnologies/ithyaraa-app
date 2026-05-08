import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interceptors/token_refresh_interceptor.dart';
import '../../data/datasources/address_remote_datasource.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/usecases/get_all_addresses_usecase.dart';
import '../../domain/usecases/add_address_usecase.dart';
import '../controllers/address_controller.dart';
import '../state/address_state.dart';

/// Provider for Dio instance for address API with token refresh interceptor
final addressDioProvider = Provider<Dio>((ref) {
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
        debugPrint('[ADDRESS DIO] REQUEST → ${options.method} ${options.path}');
        if (options.data != null) {
          debugPrint('[ADDRESS DIO] Request Body: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '[ADDRESS DIO] RESPONSE → ${response.requestOptions.path} (${response.statusCode})',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('[ADDRESS DIO] ERROR → ${error.requestOptions.path}');
        debugPrint('[ADDRESS DIO] Error: ${error.message}');
        if (error.response != null) {
          debugPrint(
            '[ADDRESS DIO] Error Status: ${error.response?.statusCode}',
          );
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

/// Provider for address remote data source
final addressRemoteDataSourceProvider = Provider<AddressRemoteDataSource>((
  ref,
) {
  final dio = ref.read(addressDioProvider);
  return AddressRemoteDataSourceImpl(dio: dio);
});

/// Provider for address repository
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final dataSource = ref.read(addressRemoteDataSourceProvider);
  return AddressRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for get all addresses use case
final getAllAddressesUseCaseProvider = Provider<GetAllAddressesUseCase>((ref) {
  final repository = ref.read(addressRepositoryProvider);
  return GetAllAddressesUseCase(repository);
});

/// Provider for add address use case
final addAddressUseCaseProvider = Provider<AddAddressUseCase>((ref) {
  final repository = ref.read(addressRepositoryProvider);
  return AddAddressUseCase(repository);
});

/// Provider for address controller
final addressControllerProvider =
    StateNotifierProvider<AddressController, AddressState>((ref) {
      return AddressController(
        getAllAddressesUseCase: ref.read(getAllAddressesUseCaseProvider),
        addAddressUseCase: ref.read(addAddressUseCaseProvider),
      );
    });
