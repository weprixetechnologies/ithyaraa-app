import 'dart:convert';
import '../../domain/entities/custom_product_detail.dart';
import '../../../variable/data/models/product_image_model.dart';
import '../../../variable/data/models/cross_sell_product_model.dart';
import '../../../variable/data/models/offer_model.dart';
import 'custom_input_model.dart';
import 'dress_type_model.dart';

class CustomProductDetailModel extends CustomProductDetailEntity {
  const CustomProductDetailModel({
    required super.productID,
    required super.productName,
    super.brand,
    super.brandID,
    super.description,
    super.regularPrice,
    super.salePrice,
    super.overridePrice,
    super.discountPercentage,
    super.rating,
    super.reviewCount,
    super.inStock,
    super.stockQuantity,
    required super.featuredImages,
    required super.galleryImages,
    required super.crossSellProducts,
    super.tab1,
    super.tab2,
    super.offer,
    super.customInputs = const [],
    super.dressTypes = const [],
    super.allowCustomerImageUpload = false,
    super.sizeChartUrl,
  });

  factory CustomProductDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse featuredImage
    List<ProductImageModel> featuredImages = [];
    final featuredImage = json['featuredImage'];
    if (featuredImage is String) {
      featuredImages = ProductImageModel.parseFromJsonString(featuredImage);
    } else if (featuredImage is List) {
      featuredImages = featuredImage
          .map((item) => ProductImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Parse galleryImage
    List<ProductImageModel> galleryImages = [];
    final galleryImage = json['galleryImage'];
    if (galleryImage is String) {
      galleryImages = ProductImageModel.parseFromJsonString(galleryImage);
    } else if (galleryImage is List) {
      galleryImages = galleryImage
          .map((item) => ProductImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Parse cross-sell products
    List<CrossSellProductModel> crossSellProducts = [];
    final crossSellData = json['crossSellProducts'] ?? json['relatedProducts'] ?? json['recommendedProducts'];
    if (crossSellData is List) {
      crossSellProducts = crossSellData
          .map((item) => CrossSellProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final regularPrice = parsePrice(json['regularPrice']);
    final salePrice = parsePrice(json['salePrice']);

    double? discountPercentage = parsePrice(json['discountPercentage']);
    if (discountPercentage == null) {
      final discountType = json['discountType'] as String?;
      final discountValue = parsePrice(json['discountValue']);
      if (discountType == 'percentage' && discountValue != null) {
        discountPercentage = discountValue;
      } else if (regularPrice != null && salePrice != null && regularPrice > 0) {
        discountPercentage = ((regularPrice - salePrice) / regularPrice) * 100;
      }
    }

    bool inStock = true;
    final stockStatus = json['inStock'] ?? json['stockStatus'] ?? json['status'];
    if (stockStatus is bool) {
      inStock = stockStatus;
    } else if (stockStatus is int) {
      inStock = stockStatus != 0;
    } else if (stockStatus is String) {
      inStock = stockStatus.toLowerCase().contains('stock') &&
          !stockStatus.toLowerCase().contains('out');
    }

    String productIDStr = '';
    final productIDValue = json['productID'];
    if (productIDValue is String) {
      productIDStr = productIDValue;
    } else if (productIDValue is int) {
      productIDStr = productIDValue.toString();
    } else if (productIDValue != null) {
      productIDStr = productIDValue.toString();
    }

    OfferModel? offer;
    if (json['offer'] != null && json['offer'] is Map<String, dynamic>) {
      offer = OfferModel.fromJson(json['offer'] as Map<String, dynamic>);
    }

    // Parse customInputs
    List<CustomInputModel> customInputs = [];
    if (json['custom_inputs'] != null) {
      final ciData = json['custom_inputs'];
      if (ciData is String) {
        try {
          final decoded = jsonDecode(ciData) as List;
          customInputs = decoded.map((e) => CustomInputModel.fromJson(e as Map<String, dynamic>)).toList();
        } catch (_) {}
      } else if (ciData is List) {
        customInputs = ciData.map((e) => CustomInputModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    // Parse dressTypes
    List<DressTypeModel> dressTypes = [];
    if (json['dressTypes'] != null) {
      final dtData = json['dressTypes'];
      if (dtData is String) {
        try {
          final decoded = jsonDecode(dtData) as List;
          dressTypes = decoded.map((e) => DressTypeModel.fromJson(e as Map<String, dynamic>)).toList();
        } catch (_) {}
      } else if (dtData is List) {
        dressTypes = dtData.map((e) => DressTypeModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    // Parse allowCustomerImageUpload
    bool allowUpload = false;
    if (json['allowCustomerImageUpload'] != null) {
      allowUpload = json['allowCustomerImageUpload'] == true || 
                    json['allowCustomerImageUpload'] == 1 || 
                    json['allowCustomerImageUpload'] == 'true' || 
                    json['allowCustomerImageUpload'] == '1';
    }

    return CustomProductDetailModel(
      productID: productIDStr,
      productName: json['productName'] as String? ?? json['name'] as String? ?? '',
      brand: json['brand'] as String?,
      brandID: json['brandID']?.toString(),
      description: json['description'] as String?,
      regularPrice: regularPrice,
      salePrice: salePrice,
      overridePrice: parsePrice(json['overridePrice']),
      discountPercentage: discountPercentage,
      rating: parsePrice(json['rating']),
      reviewCount: json['reviewCount'] as int?,
      inStock: inStock,
      stockQuantity: json['stockQuantity'] as int? ?? json['stock'] as int? ?? 0,
      featuredImages: featuredImages,
      galleryImages: galleryImages,
      crossSellProducts: crossSellProducts,
      tab1: json['tab1'] as String?,
      tab2: json['tab2'] as String?,
      offer: offer,
      customInputs: customInputs,
      dressTypes: dressTypes,
      allowCustomerImageUpload: allowUpload,
      sizeChartUrl: json['sizeChartUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'brand': brand,
      'brandID': brandID,
      'description': description,
      'regularPrice': regularPrice,
      'salePrice': salePrice,
      'overridePrice': overridePrice,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'featuredImage': featuredImages.map((img) => (img as ProductImageModel).toJson()).toList(),
      'galleryImage': galleryImages.map((img) => (img as ProductImageModel).toJson()).toList(),
      'crossSellProducts': crossSellProducts.map((p) => (p as CrossSellProductModel).toJson()).toList(),
      'tab1': tab1,
      'tab2': tab2,
      if (offer != null) 'offer': (offer as OfferModel).toJson(),
      'custom_inputs': customInputs.map((c) => (c as CustomInputModel).toJson()).toList(),
      'dressTypes': dressTypes.map((d) => (d as DressTypeModel).toJson()).toList(),
      'allowCustomerImageUpload': allowCustomerImageUpload,
      'sizeChartUrl': sizeChartUrl,
    };
  }
}
