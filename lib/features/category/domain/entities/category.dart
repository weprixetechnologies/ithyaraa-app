/// Category entity representing a product category
class CategoryEntity {
  final int categoryID;
  final String categoryName;
  final String? categoryImage;
  final String? description;
  final int? productCount;

  const CategoryEntity({
    required this.categoryID,
    required this.categoryName,
    this.categoryImage,
    this.description,
    this.productCount,
  });
}
