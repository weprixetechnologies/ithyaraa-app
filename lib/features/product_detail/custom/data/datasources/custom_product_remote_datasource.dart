import 'package:dio/dio.dart';
import '../models/custom_product_detail_model.dart';



abstract class CustomProductRemoteDataSource {
  Future<CustomProductDetailModel> getProductDetail(String productID);
}

class CustomProductRemoteDataSourceImpl implements CustomProductRemoteDataSource {
  final Dio dio;

  CustomProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<CustomProductDetailModel> getProductDetail(String productID) async {
    if (productID.isEmpty) {
      throw Exception('Invalid product ID');
    }

    try {
      final endpoint = '/api/products/details/$productID';
      final response = await dio.get(endpoint);

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final productData = responseData['product'] as Map<String, dynamic>?;
        if (productData == null) {
          throw Exception('Product data not found in API response');
        }
        return CustomProductDetailModel.fromJson(productData);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final error = data['error'] as String?;
        if (error != null && error.isNotEmpty) {
          return error;
        }
      }
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
