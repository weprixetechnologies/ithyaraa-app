/// Product image entity for product detail page
class ProductImageEntity {
  final String imgUrl;
  final String? imgAlt;

  const ProductImageEntity({
    required this.imgUrl,
    this.imgAlt,
  });
}
