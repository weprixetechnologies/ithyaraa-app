import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/custom_product_remote_datasource.dart';
import '../../data/repositories/custom_product_repository_impl.dart';
import '../../domain/repositories/custom_product_repository.dart';
import '../../domain/usecases/get_custom_product_detail_usecase.dart';
import '../controllers/custom_product_controller.dart';

final customProductDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
});

final customProductRemoteDataSourceProvider =
    Provider<CustomProductRemoteDataSource>((ref) {
      final dio = ref.watch(customProductDioProvider);
      return CustomProductRemoteDataSourceImpl(dio: dio);
    });

final customProductRepositoryProvider = Provider<CustomProductRepository>((
  ref,
) {
  final dataSource = ref.watch(customProductRemoteDataSourceProvider);
  return CustomProductRepositoryImpl(remoteDataSource: dataSource);
});

final getCustomProductDetailUseCaseProvider =
    Provider<GetCustomProductDetailUseCase>((ref) {
      final repository = ref.watch(customProductRepositoryProvider);
      return GetCustomProductDetailUseCase(repository);
    });

final customProductControllerProvider = StateNotifierProvider.autoDispose
    .family<CustomProductController, CustomProductState, String>((
      ref,
      productID,
    ) {
      if (productID.isEmpty) {
        throw Exception('Product ID cannot be empty');
      }
      final useCase = ref.watch(getCustomProductDetailUseCaseProvider);
      return CustomProductController(useCase, productID: productID);
    });
