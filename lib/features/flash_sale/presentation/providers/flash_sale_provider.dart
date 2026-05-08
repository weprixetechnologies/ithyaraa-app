import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/flash_sale_controller.dart';
import '../../data/repositories/flash_sale_repository_impl.dart';
import '../../data/datasources/flash_sale_remote_datasource.dart';

final flashSaleDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
    ),
  );
});

final flashSaleRemoteDataSourceProvider = Provider<FlashSaleRemoteDataSource>((
  ref,
) {
  final dio = ref.read(flashSaleDioProvider);
  return FlashSaleRemoteDataSourceImpl(dio: dio);
});

final flashSaleRepositoryProvider = Provider<FlashSaleRepository>((ref) {
  final dataSource = ref.read(flashSaleRemoteDataSourceProvider);
  return FlashSaleRepositoryImpl(remoteDataSource: dataSource);
});

final flashSaleControllerProvider =
    StateNotifierProvider<FlashSaleController, FlashSaleState>((ref) {
      final repository = ref.read(flashSaleRepositoryProvider);
      return FlashSaleController(repository: repository);
    });
