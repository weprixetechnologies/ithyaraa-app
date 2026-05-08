import 'dart:convert';
import '../../domain/entities/offer.dart';
import '../../../shop/data/models/product_model.dart';
import 'package:flutter/foundation.dart';

/// Offer model (data layer)
class OfferModel extends OfferEntity {
  const OfferModel({
    required super.offerID,
    required super.offerName,
    required super.offerType,
    super.buyAt,
    super.buyCount,
    super.getCount,
    super.offerMobileBanner,
    super.offerBanner,
    required super.products,
    required super.createdAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    // Parse products field - it's a JSON array of objects now
    List<ProductModel> productsList = [];
    try {
      final productsData = json['products'];
      if (productsData != null) {
        if (productsData is String) {
          // Parse JSON string
          final decoded = jsonDecode(productsData) as List;
          productsList = decoded.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (productsData is List) {
          // Already a list
          productsList = productsData.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('[OFFER MODEL] Error parsing products: $e');
      productsList = [];
    }

    // Parse createdAt
    DateTime createdAt;
    try {
      final createdAtStr = json['createdAt'] as String?;
      if (createdAtStr != null) {
        createdAt = DateTime.parse(createdAtStr);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      debugPrint('[OFFER MODEL] Error parsing createdAt: $e');
      createdAt = DateTime.now();
    }

    return OfferModel(
      offerID: json['offerID'] as String? ?? '',
      offerName: json['offerName'] as String? ?? '',
      offerType: json['offerType'] as String? ?? '',
      buyAt: json['buyAt'] != null ? (json['buyAt'] as num).toDouble() : null,
      buyCount: json['buyCount'] != null ? json['buyCount'] as int : null,
      getCount: json['getCount'] != null ? json['getCount'] as int : null,
      offerMobileBanner: json['offerMobileBanner'] as String?,
      offerBanner: json['offerBanner'] as String?,
      products: productsList,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerID': offerID,
      'offerName': offerName,
      'offerType': offerType,
      if (buyAt != null) 'buyAt': buyAt,
      if (buyCount != null) 'buyCount': buyCount,
      if (getCount != null) 'getCount': getCount,
      if (offerMobileBanner != null) 'offerMobileBanner': offerMobileBanner,
      if (offerBanner != null) 'offerBanner': offerBanner,
      'products': products.map((p) => (p as ProductModel).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
