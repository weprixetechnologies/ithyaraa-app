import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Enhanced price section with tax info and special offer
class EnhancedPriceSection extends StatelessWidget {
  final double? salePrice;
  final double? regularPrice;
  final double? discountPercentage;
  final double? specialOfferPrice;
  final VoidCallback? onSpecialOfferInfoTap;

  const EnhancedPriceSection({
    super.key,
    this.salePrice,
    this.regularPrice,
    this.discountPercentage,
    this.specialOfferPrice,
    this.onSpecialOfferInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (salePrice == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Sale Price
              Text(
                '₹${salePrice!.toStringAsFixed(0)}',
                style: AppTextStyles.price.copyWith(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
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
                    fontSize: 18,
                  ),
                ),
              ],
              // Discount Percentage
              if (discountPercentage != null && discountPercentage! > 0) ...[
                const SizedBox(width: 12),
                Text(
                  '${discountPercentage!.toStringAsFixed(0)}% OFF',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          // Tax info
          Text(
            'Inclusive of all taxes',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          // Special offer button
          if (specialOfferPrice != null && specialOfferPrice! < salePrice!) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onSpecialOfferInfoTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.purple.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get it for as low as ₹${specialOfferPrice!.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.purple.shade800,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
