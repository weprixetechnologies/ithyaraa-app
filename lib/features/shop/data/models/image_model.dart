import 'dart:convert';
import '../../domain/entities/image.dart';

/// Image model for data layer
class ImageModel extends ImageEntity {
  const ImageModel({
    required super.imgUrl,
    required super.imgAlt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      imgUrl: json['imgUrl'] as String? ?? '',
      imgAlt: json['imgAlt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imgUrl': imgUrl,
      'imgAlt': imgAlt,
    };
  }

  /// Parses a JSON string into a list of ImageModel
  /// Handles the case where featuredImage is returned as a JSON string
  static List<ImageModel> parseFromJsonString(String jsonString) {
    try {
      final decoded = json.decode(jsonString) as List;
      return decoded
          .map((item) => ImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
