import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Product info section with brand, name, and wishlist icon
class ProductInfoSection extends StatelessWidget {
  final String? brandName;
  final String productName;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;

  const ProductInfoSection({
    super.key,
    this.brandName,
    required this.productName,
    this.onWishlistTap,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Name
                if (brandName != null) ...[
                  Text(
                    brandName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                // Product Name
                Text(
                  productName,
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Wishlist icon
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.black87,
            ),
            onPressed: onWishlistTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
