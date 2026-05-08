import '../../domain/entities/search_response.dart';
import 'search_product_model.dart';

/// Search response model for data layer
class SearchResponseModel extends SearchResponseEntity {
  const SearchResponseModel({
    required super.products,
    required super.total,
    super.message,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final products = data
        .map((item) => SearchProductModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return SearchResponseModel(
      products: products,
      total: json['total'] as int? ?? 0,
      message: json['message'] as String?,
    );
  }
}
