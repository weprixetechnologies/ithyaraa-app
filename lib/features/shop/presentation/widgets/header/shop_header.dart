import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/widgets/back_button_widget.dart';

/// Shop page header widget
class ShopHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onWishlistPressed;
  final VoidCallback? onCartPressed;
  final int? cartItemCount;

  const ShopHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackPressed,
    this.onSearchPressed,
    this.onWishlistPressed,
    this.onCartPressed,
    this.cartItemCount,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Back Button
            BackButtonWidget(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Search Icon
            IconButton(
              onPressed: onSearchPressed,
              icon: const Icon(Icons.search),
              color: Colors.black87,
            ),
            // Wishlist Icon
            IconButton(
              onPressed: onWishlistPressed,
              icon: const Icon(Icons.favorite_border),
              color: Colors.black87,
            ),
            // Cart Icon with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: onCartPressed,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  color: Colors.black87,
                ),
                if (cartItemCount != null && cartItemCount! > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartItemCount! > 99 ? '99+' : cartItemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
