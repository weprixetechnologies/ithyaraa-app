import '../entities/wishlist.dart';

/// Repository interface for Wishlist operations
abstract class WishlistRepository {
  Future<WishlistEntity> getWishlist();

  /// Adds a product to the wishlist
  /// Returns the updated [WishlistEntity]
  Future<WishlistEntity> addWishlist(String productID);

  /// Removes a specific wishlist item by its ID
  /// Returns the updated [WishlistEntity]
  Future<WishlistEntity> removeWishlist(String wishlistItemID);

  /// Removes a product from the wishlist by Product ID
  /// Returns the updated [WishlistEntity]
  Future<WishlistEntity> removeProductFromWishlist(String productID);
}
