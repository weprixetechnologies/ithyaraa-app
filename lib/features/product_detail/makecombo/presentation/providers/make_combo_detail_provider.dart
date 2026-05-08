import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/interceptors/token_refresh_interceptor.dart';
import '../../data/datasources/make_combo_detail_remote_datasource.dart';
import '../../data/repositories/make_combo_detail_repository_impl.dart';
import '../../domain/repositories/make_combo_detail_repository.dart';
import '../../domain/usecases/get_make_combo_detail_usecase.dart';
import '../controllers/make_combo_detail_controller.dart';
import '../state/make_combo_detail_state.dart';

final makeComboDetailDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.add(TokenRefreshInterceptor(ref));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[DIO] REQUEST → ${options.method} ${options.path}');
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
        handler.next(error);
      },
    ),
  );
  return dio;
});

final makeComboDetailRemoteDataSourceProvider =
    Provider<MakeComboDetailRemoteDataSource>((ref) {
      final dio = ref.read(makeComboDetailDioProvider);
      return MakeComboDetailRemoteDataSourceImpl(dio: dio);
    });

final makeComboDetailRepositoryProvider = Provider<MakeComboDetailRepository>((
  ref,
) {
  final dataSource = ref.read(makeComboDetailRemoteDataSourceProvider);
  return MakeComboDetailRepositoryImpl(remoteDataSource: dataSource);
});

final getMakeComboDetailUseCaseProvider = Provider<GetMakeComboDetailUseCase>((
  ref,
) {
  final repository = ref.read(makeComboDetailRepositoryProvider);
  return GetMakeComboDetailUseCase(repository);
});

final makeComboDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<MakeComboDetailController, MakeComboDetailState, String>((
      ref,
      productID,
    ) {
      final useCase = ref.read(getMakeComboDetailUseCaseProvider);
      return MakeComboDetailController(useCase, productID: productID);
    });
