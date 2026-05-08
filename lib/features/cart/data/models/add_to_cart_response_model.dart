import '../../domain/entities/add_to_cart_response.dart';
import 'cart_item_model.dart';
import 'cart_summary_model.dart';

/// Add to cart response model
class AddToCartResponseModel extends AddToCartResponse {
  const AddToCartResponseModel({
    required super.cartItem,
    required super.cartDetail,
    super.crossSellProducts = const [],
  });

  factory AddToCartResponseModel.fromJson(Map<String, dynamic> json) {
    final cartItemJson = json['cartItem'] as Map<String, dynamic>;
    final cartItem = CartItemModel.fromJson(cartItemJson);

    final cartDetailJson = json['cartDetail'] as Map<String, dynamic>;
    final cartDetail = CartSummaryModel.fromJson(cartDetailJson);

    final crossSellProducts = (json['crossSellProducts'] as List<dynamic>?)
            ?.map((item) => CrossSellProductModel.fromJson(
                item as Map<String, dynamic>))
            .toList() ??
        [];

    return AddToCartResponseModel(
      cartItem: cartItem,
      cartDetail: cartDetail,
      crossSellProducts: crossSellProducts,
    );
  }
}

/// Cross-sell product model
class CrossSellProductModel extends CrossSellProduct {
  const CrossSellProductModel({
    required super.productID,
    required super.name,
    super.regularPrice,
    super.salePrice,
    super.imageUrl,
  });

  factory CrossSellProductModel.fromJson(Map<String, dynamic> json) {
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

    return CrossSellProductModel(
      productID: parseString(json['productID']),
      name: parseString(json['name']),
      regularPrice: parsePrice(json['regularPrice']),
      salePrice: parsePrice(json['salePrice']),
      imageUrl: parseStringNullable(json['imageUrl']),
    );
  }
}
