import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Price section widget
class PriceSection extends StatelessWidget {
  final double? salePrice;
  final double? regularPrice;
  final double? discountPercentage;

  const PriceSection({
    super.key,
    this.salePrice,
    this.regularPrice,
    this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    if (salePrice == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // Sale Price
          Text(
            '₹${salePrice!.toStringAsFixed(0)}',
            style: AppTextStyles.price.copyWith(
              color: Colors.green.shade700,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Regular Price (strikethrough)
          if (regularPrice != null && regularPrice! > salePrice!) ...[
            const SizedBox(width: 12),
            Text(
              '₹${regularPrice!.toStringAsFixed(0)}',
              style: AppTextStyles.bodyMedium.copyWith(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
          // Discount Percentage
          if (discountPercentage != null && discountPercentage! > 0) ...[
            const SizedBox(width: 12),
            Text(
              '${discountPercentage!.toStringAsFixed(0)}% OFF',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
