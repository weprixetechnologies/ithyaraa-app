import '../../domain/entities/shop_response.dart';
import 'product_model.dart';
import 'pagination_model.dart';
import 'package:flutter/foundation.dart';

/// Shop response model for data layer
class ShopResponseModel extends ShopResponseEntity {
  const ShopResponseModel({required super.products, required super.pagination});

  factory ShopResponseModel.fromJson(Map<String, dynamic> json) {
    debugPrint('[SHOP RESPONSE MODEL] Parsing response JSON');
    debugPrint('[SHOP RESPONSE MODEL] JSON keys: ${json.keys.toList()}');

    // API returns data in 'data' field, not 'products'
    final productsList =
        json['data'] as List? ?? json['products'] as List? ?? [];
    debugPrint(
      '[SHOP RESPONSE MODEL] Products list length: ${productsList.length}',
    );

    final products = productsList.map((item) {
      try {
        return ProductModel.fromJson(item as Map<String, dynamic>);
      } catch (e) {
        debugPrint('[SHOP RESPONSE MODEL] Error parsing product: $e');
        debugPrint('[SHOP RESPONSE MODEL] Product data: $item');
        rethrow;
      }
    }).toList();

    final paginationData = json['pagination'] as Map<String, dynamic>? ?? {};
    debugPrint('[SHOP RESPONSE MODEL] Pagination data: $paginationData');
    final pagination = PaginationModel.fromJson(paginationData);

    debugPrint(
      '[SHOP RESPONSE MODEL] Successfully parsed ${products.length} products',
    );
    return ShopResponseModel(products: products, pagination: pagination);
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => (p as ProductModel).toJson()).toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}
