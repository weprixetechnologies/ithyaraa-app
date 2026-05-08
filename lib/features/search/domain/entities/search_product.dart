import '../../../shop/domain/entities/image.dart';

/// Search product entity
class SearchProductEntity {
  final String productID;
  final String name;
  final String? description;
  final double? regularPrice;
  final double? salePrice;
  final String? discountType;
  final double? discountValue;
  final String? type;
  final String? status;
  final String? brand;
  final List<ImageEntity> featuredImages;
  final String? categories;
  final String? createdAt;

  const SearchProductEntity({
    required this.productID,
    required this.name,
    this.description,
    this.regularPrice,
    this.salePrice,
    this.discountType,
    this.discountValue,
    this.type,
    this.status,
    this.brand,
    required this.featuredImages,
    this.categories,
    this.createdAt,
  });
}
