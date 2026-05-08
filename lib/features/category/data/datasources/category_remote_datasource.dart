import 'package:dio/dio.dart';
import '../models/category_model.dart';
import 'package:flutter/foundation.dart';

/// Remote data source for category API
abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getAllCategories({
    int page = 1,
    int limit = 50,
    String? categoryName,
  });
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio dio;

  CategoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getAllCategories({
    int page = 1,
    int limit = 50,
    String? categoryName,
  }) async {
    debugPrint('[CATEGORY DATA SOURCE] Fetching categories - Page: $page, Limit: $limit');
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (categoryName != null && categoryName.isNotEmpty) {
        queryParams['categoryName'] = categoryName;
        debugPrint('[CATEGORY DATA SOURCE] Filter by name: $categoryName');
      }

      debugPrint('[CATEGORY DATA SOURCE] Making GET request to /api/categories/all-category');
      final response = await dio.get(
        '/api/categories/all-category',
        queryParameters: queryParams,
      );

      debugPrint('[CATEGORY DATA SOURCE] Response received successfully');
      
      // Handle different response structures
      List<dynamic> categoriesList = [];
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        // Try 'data' field first, then 'categories', then direct list
        categoriesList = data['data'] as List? ?? 
                        data['categories'] as List? ?? 
                        [];
      } else if (response.data is List) {
        categoriesList = response.data as List;
      }

      final categories = categoriesList
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('[CATEGORY DATA SOURCE] Parsed ${categories.length} categories');
      return categories;
    } on DioException catch (e) {
      debugPrint('[CATEGORY DATA SOURCE] Error occurred: ${e.message}');
      debugPrint('[CATEGORY DATA SOURCE] Error type: ${e.type}');
      if (e.response != null) {
        debugPrint('[CATEGORY DATA SOURCE] Error status code: ${e.response?.statusCode}');
        debugPrint('[CATEGORY DATA SOURCE] Error response data: ${e.response?.data}');
      }
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      debugPrint('[CATEGORY DATA SOURCE] Unexpected error: $e');
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
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Unauthorized. Please login again.';
        case 404:
          return 'Categories not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed with status $statusCode';
      }
    }

    return e.message ?? 'An unexpected error occurred';
  }
}
