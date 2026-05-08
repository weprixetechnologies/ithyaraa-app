import 'package:equatable/equatable.dart';
import '../../domain/entities/wishlist.dart';

class WishlistState extends Equatable {
  final List<WishlistItemEntity> items;
  final bool isLoading;
  final bool isWishlistHydrated;
  final String? error;

  const WishlistState({
    this.items = const [],
    this.isLoading = false,
    this.isWishlistHydrated = false,
    this.error,
  });

  WishlistState copyWith({
    List<WishlistItemEntity>? items,
    bool? isLoading,
    bool? isWishlistHydrated,
    String? error,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isWishlistHydrated: isWishlistHydrated ?? this.isWishlistHydrated,
      error: error,
    );
  }

  /// Helper to check if a product is in the wishlist
  bool containsProduct(String productID) {
    return items.any((item) => item.product.productID == productID);
  }

  @override
  List<Object?> get props => [items, isLoading, isWishlistHydrated, error];
}
