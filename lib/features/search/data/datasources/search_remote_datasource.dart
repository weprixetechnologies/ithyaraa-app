import 'package:dio/dio.dart';
import '../models/search_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';

/// Remote data source for search API
abstract class SearchRemoteDataSource {
  Future<SearchResponseModel> searchProducts(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio dio;

  SearchRemoteDataSourceImpl({required this.dio});

  @override
  Future<SearchResponseModel> searchProducts(String query) async {
    debugPrint('[SEARCH DATA SOURCE] Searching for: $query');

    try {
      final response = await dio.get(
        '/api/products/search',
        queryParameters: {'q': query},
      );

      debugPrint('[SEARCH DATA SOURCE] Response received successfully');
      final searchResponse = SearchResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      debugPrint(
        '[SEARCH DATA SOURCE] Found ${searchResponse.products.length} products',
      );

      return searchResponse;
    } on DioException catch (e) {
      debugPrint('[SEARCH DATA SOURCE] Error occurred: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '[SEARCH DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[SEARCH DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint('[SEARCH DATA SOURCE] Extracted error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[SEARCH DATA SOURCE] Unexpected error: $e');
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
          return 'Invalid search query. Please check your input.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed with status $statusCode';
      }
    }

    return e.message ?? 'An unexpected error occurred';
  }
}
