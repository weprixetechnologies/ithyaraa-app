import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Secondary actions section (Add to Wishlist, Size Guide)
class SecondaryActionsSection extends StatelessWidget {
  final VoidCallback? onAddToWishlist;
  final VoidCallback? onSizeGuide;
  final bool isWishlisted;

  const SecondaryActionsSection({
    super.key,
    this.onAddToWishlist,
    this.onSizeGuide,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Add to Wishlist
          GestureDetector(
            onTap: onAddToWishlist,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Add to Wishlist',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Size Guide
          GestureDetector(
            onTap: onSizeGuide,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.straighten,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Size Guide',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
