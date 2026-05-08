import '../../domain/entities/wishlist.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../shop/domain/entities/product.dart';

class WishlistModel extends WishlistEntity {
  const WishlistModel({required List<WishlistItemModel> items})
    : super(items: items);

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    // New API contract:
    // {
    //   "success": true,
    //   "message": "...",
    //   "data": {
    //     "items": [ { wishlistItemID, productID, ...productDetails } ],
    //     "count": number
    //   }
    // }
    final data = json['data'];
    if (data is Map<String, dynamic> && data['items'] is List) {
      final itemsList = data['items'] as List;
      return WishlistModel(
        items: itemsList
            .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    // Backward-compatible shapes:
    if (json['docs'] != null) {
      return WishlistModel(
        items: (json['docs'] as List)
            .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json['items'] != null) {
      return WishlistModel(
        items: (json['items'] as List)
            .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    // Fallback if response is logically valid but structure is slightly different or empty
    return const WishlistModel(items: []);
  }
}

class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({required String id, required ProductEntity product})
    : super(id: id, product: product);

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    // ID: support new and old keys
    final id = (json['wishlistItemID'] ?? json['_id'] ?? json['id'] ?? '')
        .toString();

    // Product details:
    // New API may either:
    // - embed full product under "product" or "productDetails"
    // - flatten product fields at the root alongside wishlistItemID/productID
    Map<String, dynamic>? productJson;

    if (json['product'] is Map<String, dynamic>) {
      productJson = json['product'] as Map<String, dynamic>;
    } else if (json['productDetails'] is Map<String, dynamic>) {
      productJson = json['productDetails'] as Map<String, dynamic>;
    } else {
      // If keys like productName/name exist at the root, treat the whole JSON
      // (minus wishlist-specific fields) as the product payload.
      final hasProductFields =
          json.containsKey('productName') || json.containsKey('name');

      if (hasProductFields) {
        final Map<String, dynamic> clone = Map<String, dynamic>.from(json);
        // Remove wishlist-specific keys so ProductModel doesn't get confused.
        clone.remove('wishlistItemID');
        clone.remove('productType');
        productJson = clone;
      }
    }

    // As a final fallback, construct a minimal product payload from IDs.
    productJson ??= <String, dynamic>{
      'productID': json['productID']?.toString() ?? '',
      'productName':
          json['productName']?.toString() ?? json['name']?.toString() ?? '',
      // Optional fields ProductModel can handle gracefully.
      'featuredImage': json['featuredImage'],
      'categories': json['categories'],
    };

    return WishlistItemModel(
      id: id,
      product: ProductModel.fromJson(productJson),
    );
  }
}
