import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../domain/entities/product.dart';

class WishlistButton extends ConsumerWidget {
  final ProductEntity product;
  final Color? iconColor;
  final Color? backgroundColor;

  const WishlistButton({
    super.key,
    required this.product,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch if product is in wishlist
    final isWishlisted = ref.watch(
      wishlistProvider.select(
        (state) => state.containsProduct(product.productID),
      ),
    );

    final defaultIconColor =
        iconColor ?? (isWishlisted ? Colors.red : Colors.white);
    final defaultBackgroundColor =
        backgroundColor ?? Colors.black.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () {
        ref
            .read(wishlistProvider.notifier)
            .toggleWishlist(product.productID, productEntity: product);
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: defaultBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          color: defaultIconColor,
          size: 18,
        ),
      ),
    );
  }
}
