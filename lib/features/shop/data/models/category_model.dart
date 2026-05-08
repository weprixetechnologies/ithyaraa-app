import 'dart:convert';
import '../../domain/entities/category.dart';

/// Category model for data layer
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.categoryID,
    required super.categoryName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryID: json['categoryID'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryID': categoryID,
      'categoryName': categoryName,
    };
  }

  /// Parses a JSON string into a list of CategoryModel
  /// Handles the case where categories is returned as a JSON string
  static List<CategoryModel> parseFromJsonString(String jsonString) {
    try {
      final decoded = json.decode(jsonString) as List;
      return decoded
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
