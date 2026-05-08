import 'package:dio/dio.dart';

abstract class FlashSaleRemoteDataSource {
  Future<Map<String, dynamic>> getFlashSaleProducts({
    int page = 1,
    int limit = 12,
    Map<String, dynamic>? filters,
  });
}

class FlashSaleRemoteDataSourceImpl implements FlashSaleRemoteDataSource {
  final Dio dio;

  FlashSaleRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getFlashSaleProducts({
    int page = 1,
    int limit = 12,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        ...?filters,
      };

      final response = await dio.get(
        '/api/flash-sale-products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch flash sale products');
      }
    } catch (e) {
      rethrow;
    }
  }
}
