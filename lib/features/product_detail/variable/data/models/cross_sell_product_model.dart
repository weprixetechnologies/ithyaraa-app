import '../../domain/entities/cross_sell_product.dart';

/// Cross-sell product model for data layer
class CrossSellProductModel extends CrossSellProductEntity {
  const CrossSellProductModel({
    required super.productID,
    required super.productName,
    super.imageUrl,
    super.salePrice,
    super.regularPrice,
    required super.productType,
  });

  factory CrossSellProductModel.fromJson(Map<String, dynamic> json) {
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Get image from featuredImage or imageUrl
    String? imageUrl;
    final featuredImage = json['featuredImage'];
    if (featuredImage is String) {
      imageUrl = featuredImage;
    } else if (featuredImage is List && featuredImage.isNotEmpty) {
      final firstImage = featuredImage[0];
      if (firstImage is Map) {
        imageUrl = firstImage['imgUrl'] as String? ?? firstImage['imageUrl'] as String?;
      }
    }
    imageUrl ??= json['imageUrl'] as String? ?? json['image'] as String?;

    // Parse productID (alphanumeric string)
    String productIDStr = '';
    final productIDValue = json['productID'] ?? json['id'];
    if (productIDValue is String) {
      productIDStr = productIDValue;
    } else if (productIDValue is int) {
      productIDStr = productIDValue.toString();
    } else if (productIDValue != null) {
      productIDStr = productIDValue.toString();
    }

    return CrossSellProductModel(
      productID: productIDStr,
      productName: json['productName'] as String? ?? 
                  json['name'] as String? ?? '',
      imageUrl: imageUrl,
      salePrice: parsePrice(json['salePrice']),
      regularPrice: parsePrice(json['regularPrice']),
      productType: json['type'] as String? ?? 
                   json['productType'] as String? ?? 
                   'variable',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'imageUrl': imageUrl,
      'salePrice': salePrice,
      'regularPrice': regularPrice,
      'type': productType,
    };
  }
}
