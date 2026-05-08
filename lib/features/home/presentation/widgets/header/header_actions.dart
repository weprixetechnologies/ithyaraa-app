import 'package:flutter/material.dart';
import 'cart_icon_with_badge.dart';
import 'wishlist_icon_with_badge.dart';

/// Header Actions container widget
///
/// Contains: Search, Wishlist, Cart buttons
/// Stateless widget - no rebuilds needed
/// Badge updates are handled by isolated Consumer widgets
class HeaderActions extends StatelessWidget {
  final VoidCallback? onSearchPressed;
  final VoidCallback? onWishlistPressed;
  final VoidCallback? onCartPressed;

  const HeaderActions({
    super.key,
    this.onSearchPressed,
    this.onWishlistPressed,
    this.onCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search icon
        IconButton(
          onPressed: onSearchPressed,
          icon: const Icon(
            Icons.search_rounded,
            size: 28,
            color: Colors.black87,
          ),
          splashRadius: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        // Wishlist Icon with Badge
        WishlistIconWithBadge(onPressed: onWishlistPressed),
        const SizedBox(width: 4),
        // Cart Icon with Badge
        CartIconWithBadge(onPressed: onCartPressed),
      ],
    );
  }
}
