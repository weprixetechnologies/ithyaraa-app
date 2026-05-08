import '../../domain/entities/order_item.dart';
import '../../domain/entities/combo_item.dart';
import 'combo_item_model.dart';
import 'dart:developer' as developer;
import 'dart:convert';

/// Order item model for data layer
class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.orderItemID,
    required super.orderID,
    required super.productID,
    required super.productName,
    required super.quantity,
    required super.price,
    super.imageUrl,
    super.variationID,
    super.storedVariationName,
    super.variationValues,
    super.salePrice,
    super.regularPrice,
    super.unitPriceBefore,
    super.unitPriceAfter,
    super.lineTotalBefore,
    super.lineTotalAfter,
    super.trackingCode,
    super.deliveryCompany,
    super.itemStatus,
    super.productType,
    super.createdAt,
    super.featuredImages,
    super.variant,
    super.shippingAddress,
    super.email,
    super.contactNumber,
    super.comboItems,
    super.customInputs,
    super.brand,
    super.returnStatus,
    super.returnRequestedAt,
    super.returnRejectionReason,
    super.returnTrackingCode,
    super.returnTrackingUrl,
    super.returnDeliveryCompany,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values (handles both String and num)
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 1;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 1;
      }
      return 1;
    }

    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return null;
      }
    }

    // Parse featured images
    List<Map<String, dynamic>>? _parseImages(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
      }
      return null;
    }

    // Get first image URL from featuredImages array
    String? _getFirstImageUrl(dynamic featuredImages) {
      if (featuredImages is List && featuredImages.isNotEmpty) {
        final firstImage = featuredImages.first;
        if (firstImage is Map<String, dynamic>) {
          return firstImage['imgUrl']?.toString();
        }
      }
      return json['imageUrl']?.toString() ?? json['image']?.toString();
    }

    final featuredImages = json['featuredImage'] as List?;
    final firstImageUrl = _getFirstImageUrl(featuredImages);

    // Helper function to safely parse orderID (handles int, String, and null)
    String _parseOrderID(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int || value is num) return value.toString();
      return value.toString();
    }

    // Parse comboItems: lightweight product snapshots (NOT full order items)
    // API uses exact key "comboItems" (not snake_case)
    // Combo sub-items don't have quantity, pricing, totals, tracking
    List<ComboItemEntity>? _parseComboItems(dynamic value) {
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

    // Parse variationValues
    List<Map<String, dynamic>>? _parseVariationValues(dynamic value) {
      // Log raw API value
      developer.log(
        'API variationValues (raw): $value',
        name: 'OrderItemModel',
      );
      
      if (value == null) {
        developer.log(
          'variationValues is null',
          name: 'OrderItemModel',
        );
        return null;
      }
      
      // Handle String case - API sometimes returns JSON string
      dynamic parsedValue = value;
      if (value is String) {
        developer.log(
          'variationValues is a String, parsing JSON...',
          name: 'OrderItemModel',
        );
        try {
          parsedValue = jsonDecode(value);
          developer.log(
            'JSON decoded: $parsedValue',
            name: 'OrderItemModel',
          );
        } catch (e) {
          developer.log(
            'Failed to parse JSON string: $e',
            name: 'OrderItemModel',
          );
          return null;
        }
      }
      
      if (parsedValue is List) {
        final parsed = parsedValue.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
        
        developer.log(
          'variationValues parsed: $parsed',
          name: 'OrderItemModel',
        );
        
        return parsed;
      }
      
      developer.log(
        'variationValues is not a List after parsing, type: ${parsedValue.runtimeType}',
        name: 'OrderItemModel',
      );
      return null;
    }

    // Parse custom_inputs: Map<String, dynamic> from API
    Map<String, dynamic>? _parseCustomInputs(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) {
        return Map<String, dynamic>.from(value);
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    // Log product info and variationValues from API
    final productName = json['name']?.toString() ?? json['productName']?.toString() ?? '';
    final rawVariationValues = json['variationValues'];
    
    developer.log(
      'Parsing OrderItem - Product: $productName',
      name: 'OrderItemModel',
    );
    developer.log(
      '  API json[\'variationValues\']: $rawVariationValues',
      name: 'OrderItemModel',
    );
    
    final parsedVariationValues = _parseVariationValues(rawVariationValues);
    
    return OrderItemModel(
      orderItemID: json['orderItemID']?.toString() ?? '',
      orderID: _parseOrderID(json['orderID']),
      productID:
          json['productID']?.toString() ?? json['productId']?.toString() ?? '',
      productName: productName,
      quantity: _parseInt(json['quantity']),
      price: _parseDouble(json['lineTotalAfter'] ?? json['price']),
      imageUrl: firstImageUrl,
      variationID: json['variationID']?.toString(),
      storedVariationName: json['storedVariationName']?.toString(),
      variationValues: parsedVariationValues,
      salePrice: json['salePrice'] != null
          ? _parseDouble(json['salePrice'])
          : null,
      regularPrice: json['regularPrice'] != null
          ? _parseDouble(json['regularPrice'])
          : null,
      unitPriceBefore: json['unitPriceBefore'] != null
          ? _parseDouble(json['unitPriceBefore'])
          : null,
      unitPriceAfter: json['unitPriceAfter'] != null
          ? _parseDouble(json['unitPriceAfter'])
          : null,
      lineTotalBefore: json['lineTotalBefore'] != null
          ? _parseDouble(json['lineTotalBefore'])
          : null,
      lineTotalAfter: json['lineTotalAfter'] != null
          ? _parseDouble(json['lineTotalAfter'])
          : null,
      trackingCode: json['trackingCode']?.toString(),
      deliveryCompany: json['deliveryCompany']?.toString(),
      itemStatus: json['itemStatus']?.toString(),
      productType: json['productType']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      featuredImages: _parseImages(featuredImages),
      variant: json['variant'] as Map<String, dynamic>?,
      shippingAddress: json['shippingAddress']?.toString(),
      email: json['email']?.toString(),
      contactNumber: json['contactNumber']?.toString(),
      // Parse comboItems: API uses exact key "comboItems" (not snake_case)
      // Supports both pre-defined combos and make-combo products
      comboItems: _parseComboItems(json['comboItems']),
      // Parse custom_inputs: user-provided custom data
      customInputs: _parseCustomInputs(
        json['custom_inputs'] ?? json['customInputs'],
      ),
      // Parse brand: displayed for combo sub-items
      brand: json['brand']?.toString() ?? json['brandName']?.toString(),
      // Parse return support fields
      returnStatus: json['returnStatus']?.toString(),
      returnRequestedAt: _parseDate(json['returnRequestedAt']),
      returnRejectionReason: json['returnRejectionReason']?.toString(),
      returnTrackingCode: json['returnTrackingCode']?.toString(),
      returnTrackingUrl: json['returnTrackingUrl']?.toString(),
      returnDeliveryCompany: json['returnDeliveryCompany']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (variant != null) 'variant': variant,
    };
  }
}
