import '../../domain/entities/category.dart';

/// Category model for data layer
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.categoryID,
    required super.categoryName,
    super.categoryImage,
    super.description,
    super.productCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // API returns featuredImage as the category image
    final featuredImage = json['featuredImage'] as String?;
    
    return CategoryModel(
      categoryID: json['categoryID'] as int? ?? 
                  (json['id'] as int? ?? 0),
      categoryName: json['categoryName'] as String? ?? 
                    json['name'] as String? ?? '',
      // Map featuredImage from API to categoryImage in entity
      categoryImage: featuredImage ?? 
                    json['categoryImage'] as String? ?? 
                    json['image'] as String? ?? 
                    json['imageUrl'] as String?,
      description: json['description'] as String?,
      productCount: json['productCount'] as int? ?? 
                   json['product_count'] as int? ??
                   json['count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryID': categoryID,
      'categoryName': categoryName,
      'categoryImage': categoryImage,
      'description': description,
      'productCount': productCount,
    };
  }
}
