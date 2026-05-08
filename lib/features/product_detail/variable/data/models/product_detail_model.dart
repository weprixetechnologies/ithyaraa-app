import 'dart:convert';
import '../../domain/entities/product_detail.dart';
import 'product_image_model.dart';
import 'product_attribute_model.dart';
import 'variation_model.dart';
import 'cross_sell_product_model.dart';
import 'offer_model.dart';
import 'package:flutter/foundation.dart';

/// Product detail model for data layer
class ProductDetailModel extends ProductDetailEntity {
  const ProductDetailModel({
    required super.productID,
    required super.productName,
    super.brand,
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
    required super.productAttributes,
    required super.variations,
    required super.crossSellProducts,
    super.tab1,
    super.tab2,
    super.offer,
    super.isFlashSale = false,
    super.flashSaleEndTime,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    debugPrint(
      '[PRODUCT DETAIL MODEL] Parsing product detail for ID: ${json['productID']}',
    );

    // Parse featuredImage - can be JSON string or List
    List<ProductImageModel> featuredImages = [];
    final featuredImage = json['featuredImage'];
    if (featuredImage is String) {
      featuredImages = ProductImageModel.parseFromJsonString(featuredImage);
    } else if (featuredImage is List) {
      featuredImages = featuredImage
          .map(
            (item) => ProductImageModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    debugPrint(
      '[PRODUCT DETAIL MODEL] Parsed ${featuredImages.length} featured images',
    );

    // Parse galleryImage - can be JSON string or List
    List<ProductImageModel> galleryImages = [];
    final galleryImage = json['galleryImage'];
    if (galleryImage is String) {
      galleryImages = ProductImageModel.parseFromJsonString(galleryImage);
    } else if (galleryImage is List) {
      galleryImages = galleryImage
          .map(
            (item) => ProductImageModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    debugPrint(
      '[PRODUCT DETAIL MODEL] Parsed ${galleryImages.length} gallery images',
    );

    // Parse productAttributes - structure: [{"name":"Size","values":["S","M","L"]}]
    // We need to expand this into individual attribute-value pairs for variations
    List<ProductAttributeModel> productAttributes = [];
    final productAttributesData = json['productAttributes'];
    if (productAttributesData is String) {
      try {
        final decoded = jsonDecode(productAttributesData) as List;
        for (final attrDef in decoded) {
          if (attrDef is Map<String, dynamic>) {
            final attrName = attrDef['name'] as String? ?? '';
            final values = attrDef['values'] as List?;
            if (values != null) {
              for (final value in values) {
                productAttributes.add(
                  ProductAttributeModel(
                    attributeName: attrName,
                    attributeValue: value.toString(),
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint(
          '[PRODUCT DETAIL MODEL] Error parsing productAttributes JSON string: $e',
        );
      }
    } else if (productAttributesData is List) {
      for (final attrDef in productAttributesData) {
        if (attrDef is Map<String, dynamic>) {
          final attrName = attrDef['name'] as String? ?? '';
          final values = attrDef['values'] as List?;
          if (values != null) {
            for (final value in values) {
              productAttributes.add(
                ProductAttributeModel(
                  attributeName: attrName,
                  attributeValue: value.toString(),
                ),
              );
            }
          }
        }
      }
    }
    debugPrint(
      '[PRODUCT DETAIL MODEL] Parsed ${productAttributes.length} product attributes',
    );

    // Parse variations
    List<VariationModel> variations = [];
    final variationsData = json['variations'];
    if (variationsData is List) {
      variations = variationsData
          .map((item) => VariationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    debugPrint('[PRODUCT DETAIL MODEL] Parsed ${variations.length} variations');

    // Parse cross-sell products
    List<CrossSellProductModel> crossSellProducts = [];
    final crossSellData =
        json['crossSellProducts'] ??
        json['relatedProducts'] ??
        json['recommendedProducts'];
    if (crossSellData is List) {
      crossSellProducts = crossSellData
          .map(
            (item) =>
                CrossSellProductModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    debugPrint(
      '[PRODUCT DETAIL MODEL] Parsed ${crossSellProducts.length} cross-sell products',
    );

    // Parse prices
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Parse prices (can be strings from API)
    final regularPrice = parsePrice(json['regularPrice']);
    final salePrice = parsePrice(json['salePrice']);

    // Calculate discount percentage
    // API provides discountType and discountValue, or calculate from prices
    double? discountPercentage = parsePrice(json['discountPercentage']);
    if (discountPercentage == null) {
      final discountType = json['discountType'] as String?;
      final discountValue = parsePrice(json['discountValue']);
      if (discountType == 'percentage' && discountValue != null) {
        discountPercentage = discountValue;
      } else if (regularPrice != null &&
          salePrice != null &&
          regularPrice > 0) {
        discountPercentage = ((regularPrice - salePrice) / regularPrice) * 100;
      }
    }

    // Parse stock status
    bool inStock = true;
    final stockStatus =
        json['inStock'] ?? json['stockStatus'] ?? json['status'];
    if (stockStatus is bool) {
      inStock = stockStatus;
    } else if (stockStatus is int) {
      // Handle int values: 0 = false, non-zero = true
      inStock = stockStatus != 0;
    } else if (stockStatus is String) {
      inStock =
          stockStatus.toLowerCase().contains('stock') &&
          !stockStatus.toLowerCase().contains('out');
    }

    // Parse productID (alphanumeric string)
    String productIDStr = '';
    final productIDValue =
        json['productID'] ??
        json['presaleProductID'] ??
        json['id'] ??
        json['ProductID'];

    if (productIDValue is String) {
      productIDStr = productIDValue;
    } else if (productIDValue is int) {
      productIDStr = productIDValue.toString();
    } else if (productIDValue != null) {
      productIDStr = productIDValue.toString();
    }

    // Parse offer
    OfferModel? offer;
    if (json['offer'] != null && json['offer'] is Map<String, dynamic>) {
      offer = OfferModel.fromJson(json['offer'] as Map<String, dynamic>);
      debugPrint('[PRODUCT DETAIL MODEL] Parsed offer: ${offer.offerName}');
    }

    // Parse flash sale info
    final bool isFlashSale =
        json['isFlashSale'] == true || json['isFlashSale'] == 1;
    DateTime? flashSaleEndTime;
    if (json['flashSaleEndTime'] != null) {
      flashSaleEndTime = DateTime.tryParse(json['flashSaleEndTime'].toString());
    }

    return ProductDetailModel(
      productID: productIDStr,
      productName:
          json['productName'] as String? ?? json['name'] as String? ?? '',
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      regularPrice: regularPrice,
      salePrice: salePrice,
      overridePrice: parsePrice(json['overridePrice']),
      discountPercentage: discountPercentage,
      rating: parsePrice(json['rating']),
      reviewCount: json['reviewCount'] as int?,
      inStock: inStock,
      stockQuantity:
          json['stockQuantity'] as int? ?? json['stock'] as int? ?? 0,
      featuredImages: featuredImages,
      galleryImages: galleryImages,
      productAttributes: productAttributes,
      variations: variations,
      crossSellProducts: crossSellProducts,
      tab1: json['tab1'] as String?,
      tab2: json['tab2'] as String?,
      offer: offer,
      isFlashSale: isFlashSale,
      flashSaleEndTime: flashSaleEndTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'brand': brand,
      'description': description,
      'regularPrice': regularPrice,
      'salePrice': salePrice,
      'overridePrice': overridePrice,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'featuredImage': featuredImages
          .map((img) => (img as ProductImageModel).toJson())
          .toList(),
      'galleryImage': galleryImages
          .map((img) => (img as ProductImageModel).toJson())
          .toList(),
      'productAttributes': productAttributes
          .map((attr) => (attr as ProductAttributeModel).toJson())
          .toList(),
      'variations': variations
          .map((v) => (v as VariationModel).toJson())
          .toList(),
      'crossSellProducts': crossSellProducts
          .map((p) => (p as CrossSellProductModel).toJson())
          .toList(),
      'tab1': tab1,
      'tab2': tab2,
      'isFlashSale': isFlashSale,
      'flashSaleEndTime': flashSaleEndTime?.toIso8601String(),
      if (offer != null) 'offer': (offer as OfferModel).toJson(),
    };
  }
}
