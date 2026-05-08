import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/shop_response_model.dart';
import '../../domain/entities/shop_filters.dart';

ShopResponseModel _parseShopResponse(Map<String, dynamic> data) {
  return ShopResponseModel.fromJson(data);
}

/// Remote data source for shop API
abstract class ShopRemoteDataSource {
  Future<ShopResponseModel> getShopProducts({
    int page = 1,
    int limit = 20,
    ShopFilters? filters,
  });
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final Dio dio;

  ShopRemoteDataSourceImpl({required this.dio});

  @override
  Future<ShopResponseModel> getShopProducts({
    int page = 1,
    int limit = 20,
    ShopFilters? filters,
  }) async {
    debugPrint(
      '[SHOP DATA SOURCE] Fetching shop products - Page: $page, Limit: $limit',
    );
    if (filters != null) {
      debugPrint('[SHOP DATA SOURCE] Filters: $filters');
    }

    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (filters != null) {
        if (filters.search != null && filters.search!.isNotEmpty) {
          queryParams['search'] = filters.search;
          debugPrint('[SHOP DATA SOURCE] Search query: ${filters.search}');
        }
        if (filters.sortBy != null && filters.sortBy!.isNotEmpty) {
          queryParams['sortBy'] = filters.sortBy;
          debugPrint('[SHOP DATA SOURCE] Sort by: ${filters.sortBy}');
        }
        if (filters.sortOrder != null && filters.sortOrder!.isNotEmpty) {
          queryParams['sortOrder'] = filters.sortOrder;
          debugPrint('[SHOP DATA SOURCE] Sort order: ${filters.sortOrder}');
        }
        // Handle categoryIDs - API expects comma-separated string
        if (filters.categoryIDs != null && filters.categoryIDs!.isNotEmpty) {
          // Filter out any invalid IDs (zero or negative) and convert to string
          final validCategoryIDs = filters.categoryIDs!
              .where((id) => id > 0)
              .toList();
          if (validCategoryIDs.isNotEmpty) {
            queryParams['categoryID'] = validCategoryIDs.join(',');
            debugPrint(
              '[SHOP DATA SOURCE] Category IDs: ${filters.categoryIDs} -> ${validCategoryIDs.join(",")}',
            );
          } else {
            debugPrint(
              '[SHOP DATA SOURCE] Warning: All category IDs were invalid or zero',
            );
          }
        }
        if (filters.brandIDs != null && filters.brandIDs!.isNotEmpty) {
          queryParams['brandID'] = filters.brandIDs!.join(',');
          debugPrint('[SHOP DATA SOURCE] Brand IDs: ${filters.brandIDs}');
        }
        if (filters.sectionid != null && filters.sectionid!.isNotEmpty) {
          queryParams['sectionid'] = filters.sectionid;
          debugPrint('[SHOP DATA SOURCE] Section ID: ${filters.sectionid}');
        }
        // Product type filter - only send if it's a specific type
        // Do NOT send when type is null, empty, or explicitly "all"
        if (filters.type != null &&
            filters.type!.isNotEmpty &&
            filters.type!.toLowerCase() != 'all') {
          queryParams['type'] = filters.type;
          debugPrint('[SHOP DATA SOURCE] Type: ${filters.type}');
        } else {
          debugPrint('[SHOP DATA SOURCE] Type not applied (value: ${filters.type})');
        }
        if (filters.offerID != null && filters.offerID!.isNotEmpty) {
          queryParams['offerID'] = filters.offerID;
          debugPrint('[SHOP DATA SOURCE] Offer ID: ${filters.offerID}');
        }
        // Price bands (comma-separated) - takes precedence over minPrice/maxPrice
        if (filters.priceBands != null && filters.priceBands!.isNotEmpty) {
          queryParams['priceBands'] = filters.priceBands;
          debugPrint('[SHOP DATA SOURCE] Price bands: ${filters.priceBands}');
        } else {
          // Only use minPrice/maxPrice if priceBands is not set
          if (filters.minPrice != null) {
            queryParams['minPrice'] = filters.minPrice;
            debugPrint('[SHOP DATA SOURCE] Min price: ${filters.minPrice}');
          }
          if (filters.maxPrice != null) {
            queryParams['maxPrice'] = filters.maxPrice;
            debugPrint('[SHOP DATA SOURCE] Max price: ${filters.maxPrice}');
          }
        }
        if (filters.stock != null && filters.stock!.isNotEmpty) {
          queryParams['stock'] = filters.stock;
          debugPrint('[SHOP DATA SOURCE] Stock filter: ${filters.stock}');
        }
      }

      debugPrint('[SHOP DATA SOURCE] Making GET request to /api/products/shop');
      final response = await dio.get(
        '/api/products/shop',
        queryParameters: queryParams,
      );

      debugPrint('[SHOP DATA SOURCE] Response received successfully');
      final shopResponse = await compute(
        _parseShopResponse,
        response.data as Map<String, dynamic>,
      );
      debugPrint(
        '[SHOP DATA SOURCE] Parsed ${shopResponse.products.length} products',
      );
      debugPrint(
        '[SHOP DATA SOURCE] Pagination - Current: ${shopResponse.pagination.currentPage}, Total: ${shopResponse.pagination.totalPages}, HasNext: ${shopResponse.pagination.hasNextPage}',
      );

      return shopResponse;
    } on DioException catch (e) {
      debugPrint('[SHOP DATA SOURCE] Error occurred: ${e.message}');
      debugPrint('[SHOP DATA SOURCE] Error type: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '[SHOP DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint('[SHOP DATA SOURCE] Error response data: ${e.response?.data}');
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint('[SHOP DATA SOURCE] Extracted error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[SHOP DATA SOURCE] Unexpected error: $e');
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
          return 'Products not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed with status $statusCode';
      }
    }

    return e.message ?? 'An unexpected error occurred';
  }
}
