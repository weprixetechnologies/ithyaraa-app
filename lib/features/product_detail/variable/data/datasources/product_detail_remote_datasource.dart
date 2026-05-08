import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product_detail_model.dart';

ProductDetailModel _parseProductDetailResponse(Map<String, dynamic> data) {
  // API returns data in 'product' field: {"success": true, "product": {...}}
  final productData = data['product'] as Map<String, dynamic>?;
  if (productData == null) {
    throw Exception('Product data not found in API response');
  }
  return ProductDetailModel.fromJson(productData);
}

/// Remote data source for product detail API
abstract class ProductDetailRemoteDataSource {
  Future<ProductDetailModel> getProductDetail(String productID);
}

class ProductDetailRemoteDataSourceImpl
    implements ProductDetailRemoteDataSource {
  final Dio dio;

  ProductDetailRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProductDetailModel> getProductDetail(String productID) async {
    // Validate productID
    if (productID.isEmpty) {
      throw Exception('Invalid product ID: Product ID cannot be empty.');
    }

    debugPrint(
      '[PRODUCT DETAIL DATA SOURCE] Fetching product detail for ID: $productID',
    );

    try {
      // Ensure productID is complete and properly formatted in the URL
      final endpoint = '/api/products/details/$productID';
      debugPrint('[PRODUCT DETAIL DATA SOURCE] Making GET request to $endpoint');
      final response = await dio.get(endpoint);

      debugPrint('[PRODUCT DETAIL DATA SOURCE] Response received successfully');
      debugPrint(
        '[PRODUCT DETAIL DATA SOURCE] Response status: ${response.statusCode}',
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final productDetail = await compute(_parseProductDetailResponse, responseData);
        debugPrint(
          '[PRODUCT DETAIL DATA SOURCE] Successfully parsed product detail: ${productDetail.productName}',
        );
        return productDetail;
      } else {
        throw Exception('Invalid response format from product detail API');
      }
    } on DioException catch (e) {
      debugPrint('[PRODUCT DETAIL DATA SOURCE] Error occurred: ${e.message}');
      debugPrint('[PRODUCT DETAIL DATA SOURCE] Error type: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '[PRODUCT DETAIL DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[PRODUCT DETAIL DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint(
        '[PRODUCT DETAIL DATA SOURCE] Extracted error message: $errorMessage',
      );
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[PRODUCT DETAIL DATA SOURCE] Unexpected error: $e');
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
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid product ID.';
        case 404:
          return 'Product not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed with status $statusCode';
      }
    }

    return e.message ?? 'An unexpected error occurred';
  }
}
