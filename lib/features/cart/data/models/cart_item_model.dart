import '../../domain/entities/cart_item.dart';
import '../../../../features/order/domain/entities/combo_item.dart';
import '../../../../features/order/data/models/combo_item_model.dart';
import 'dart:convert';

/// Cart item model for data layer
///
/// Parses hierarchy fields from API to match Order Detail Page structure:
/// - comboItems: nested children for combo/make_combo products
/// - customInputs: user-provided data for custom products
/// - variationValues: key-value pairs for variable products
class CartItemModel extends CartItem {
  const CartItemModel({
    required super.cartItemID,
    required super.productID,
    required super.quantity,
    required super.name,
    super.regularPrice,
    super.salePrice,
    super.variationID,
    super.variationName,
    super.unitPriceBefore,
    super.unitPriceAfter,
    super.lineTotalBefore,
    super.lineTotalAfter,
    super.offerApplied,
    super.offerStatus,
    super.selected,
    super.isFlashSale,
    super.comboID,
    super.productType,
    super.imageUrl,
    super.brand,
    super.variationValues,
    super.comboItems,
    super.customInputs,
    super.isAvailable = true,
    super.stockStatus = 'in_stock',
    super.variationStock,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int) return value.toString();
      if (value is num) return value.toString();
      return value.toString();
    }

    String? parseStringNullable(dynamic value) {
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      if (value is int) return value.toString();
      if (value is num) return value.toString();
      return value.toString();
    }

    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) {
        return value != 0; // Handle int values: 0 = false, non-zero = true
      }
      if (value is String) {
        final lower = value.toLowerCase();
        return lower == 'true' || lower == '1' || lower == 'yes';
      }
      return false;
    }

    // Parse comboItems: lightweight product snapshots (same as OrderItemModel)
    List<ComboItemEntity>? parseComboItems(dynamic value) {
      if (value == null) return null;
      if (value is List && value.isNotEmpty) {
        return value
            .map((item) {
              if (item is Map<String, dynamic>) {
                return ComboItemModel.fromJson(item);
              }
              return null;
            })
            .whereType<ComboItemEntity>()
            .toList();
      }
      return null;
    }

    // Parse variationValues: List<Map<String, dynamic>> with key-value pairs
    List<Map<String, dynamic>>? parseVariationValues(dynamic value) {
      if (value == null) return null;

      // Handle String case - API sometimes returns JSON string
      dynamic parsedValue = value;
      if (value is String) {
        try {
          parsedValue = jsonDecode(value);
        } catch (e) {
          return null;
        }
      }

      if (parsedValue is List) {
        return parsedValue.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
      }

      return null;
    }

    // Parse custom_inputs: Map<String, dynamic> from API
    Map<String, dynamic>? parseCustomInputs(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) {
        return Map<String, dynamic>.from(value);
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    // Parse featuredImage: API returns as JSON string or raw List
    List<Map<String, dynamic>>? parseFeaturedImages(dynamic value) {
      if (value == null) return null;

      dynamic parsedValue = value;
      if (value is String) {
        try {
          parsedValue = jsonDecode(value);
        } catch (e) {
          return null;
        }
      }

      if (parsedValue is List) {
        return parsedValue.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
      }

      return null;
    }

    // Get first image URL from featuredImage array or multiple fallback fields
    String? getFirstImageUrl(
      List<Map<String, dynamic>>? featuredImages,
      Map<String, dynamic> json,
    ) {
      // 1. Array check
      if (featuredImages != null && featuredImages.isNotEmpty) {
        for (var img in featuredImages) {
          final url = img['imgUrl']?.toString();
          if (url != null && url.isNotEmpty) return url;
        }
      }

      // 2. Direct field fallbacks
      final directUrl =
          json['imageUrl'] ?? json['image'] ?? json['featured_image'];
      if (directUrl != null) {
        final url = directUrl.toString();
        if (url.isNotEmpty) return url;
      }

      return null;
    }

    final featuredImages = parseFeaturedImages(json['featuredImage']);
    final imageUrl = getFirstImageUrl(featuredImages, json);

    return CartItemModel(
      cartItemID: parseString(json['cartItemID']),
      productID: parseString(json['productID']),
      quantity: parseInt(json['quantity'], defaultValue: 1),
      name: parseString(json['name']),
      regularPrice: parsePrice(json['regularPrice']),
      salePrice: parsePrice(json['salePrice']),
      variationID: parseStringNullable(json['variationID']),
      variationName: parseStringNullable(json['variationName']),
      unitPriceBefore: parsePrice(json['unitPriceBefore']),
      unitPriceAfter: parsePrice(json['unitPriceAfter']),
      lineTotalBefore: parsePrice(json['lineTotalBefore']),
      lineTotalAfter: parsePrice(json['lineTotalAfter']),
      offerApplied: parseBool(json['offerApplied']),
      offerStatus: parseString(json['offerStatus']).isEmpty
          ? 'none'
          : parseString(json['offerStatus']),
      selected: parseInt(json['selected'], defaultValue: 0),
      isFlashSale: parseInt(json['isFlashSale'], defaultValue: 0),
      comboID: parseStringNullable(json['comboID']),
      productType: parseStringNullable(json['productType']),
      // Hierarchy support fields
      imageUrl: imageUrl,
      brand: parseStringNullable(json['brand'] ?? json['brandName']),
      variationValues: parseVariationValues(json['variationValues']),
      comboItems: parseComboItems(json['comboItems']),
      customInputs: parseCustomInputs(
        json['custom_inputs'] ?? json['customInputs'],
      ),
      isAvailable: parseBool(json['isAvailable'] ?? true),
      stockStatus: parseStringNullable(json['stockStatus']) ?? 'in_stock',
      variationStock: parseInt(json['variationStock'], defaultValue: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemID': cartItemID,
      'productID': productID,
      'quantity': quantity,
      'name': name,
      'regularPrice': regularPrice,
      'salePrice': salePrice,
      'variationID': variationID,
      'variationName': variationName,
      'unitPriceBefore': unitPriceBefore,
      'unitPriceAfter': unitPriceAfter,
      'lineTotalBefore': lineTotalBefore,
      'lineTotalAfter': lineTotalAfter,
      'offerApplied': offerApplied,
      'offerStatus': offerStatus,
      'selected': selected,
      'isFlashSale': isFlashSale,
      'comboID': comboID,
      'productType': productType,
      'imageUrl': imageUrl,
      'brand': brand,
      'variationValues': variationValues,
      // Note: comboItems serialization not needed for cart operations
      'customInputs': customInputs,
      'isAvailable': isAvailable,
      'stockStatus': stockStatus,
      'variationStock': variationStock,
    };
  }
}
