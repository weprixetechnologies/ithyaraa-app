import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/home/presentation/widgets/header/cart_icon_with_badge.dart';
import '../../../../features/home/presentation/widgets/header/wishlist_icon_with_badge.dart';

/// Offer page header widget
///
/// EDGE-TO-EDGE:
/// - Extends behind status bar with transparent status bar
/// - topPadding accounts for status bar height to prevent icon overlap
class OfferHeader extends StatelessWidget {
  final VoidCallback? onFilterPressed;
  final VoidCallback? onCartPressed;
  final VoidCallback? onWishlistPressed;
  final double topPadding;

  const OfferHeader({
    super.key,
    this.onFilterPressed,
    this.onCartPressed,
    this.onWishlistPressed,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFD232),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Title
          Text(
            'Offers',
            style: AppTextStyles.headingMedium,
          ),
          const Spacer(),
          // Filter Icon
          GestureDetector(
            onTap: onFilterPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.filter_list,
                size: 26,
                color: Colors.black87,
              ),
            ),
          ),
          // Wishlist Icon with Badge (isolated Consumer)
          WishlistIconWithBadge(onPressed: onWishlistPressed),
          // Cart Icon with Badge (isolated Consumer)
          CartIconWithBadge(onPressed: onCartPressed),
        ],
      ),
    );
  }
}
