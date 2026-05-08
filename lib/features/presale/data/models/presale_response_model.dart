import '../../../shop/data/models/pagination_model.dart';
import 'presale_product_model.dart';

class PresaleResponseModel {
  final List<PresaleProductModel> products;
  final PaginationModel pagination;

  const PresaleResponseModel({
    required this.products,
    required this.pagination,
  });

  factory PresaleResponseModel.fromJson(Map<String, dynamic> json) {
    final productsList = json['data'] as List? ?? [];
    final products = productsList
        .map((item) => PresaleProductModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final paginationData = json['pagination'] as Map<String, dynamic>? ?? {};
    final pagination = PaginationModel.fromJson(paginationData);

    return PresaleResponseModel(
      products: products,
      pagination: pagination,
    );
  }
}
