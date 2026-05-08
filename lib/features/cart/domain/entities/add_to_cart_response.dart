import 'cart_item.dart';
import 'cart_summary.dart';

/// Response from add to cart API
class AddToCartResponse {
  final CartItem cartItem;
  final CartSummary cartDetail;
  final List<CrossSellProduct> crossSellProducts;

  const AddToCartResponse({
    required this.cartItem,
    required this.cartDetail,
    this.crossSellProducts = const [],
  });
}

/// Cross-sell product entity
class CrossSellProduct {
  final String productID;
  final String name;
  final double? regularPrice;
  final double? salePrice;
  final String? imageUrl;

  const CrossSellProduct({
    required this.productID,
    required this.name,
    this.regularPrice,
    this.salePrice,
    this.imageUrl,
  });
}
