import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Product info section matching screenshot design
class ProductInfoSectionV2 extends StatelessWidget {
  final String? brandName;
  final String productName;
  final double? rating;
  final int? reviewCount;

  const ProductInfoSectionV2({
    super.key,
    this.brandName,
    required this.productName,
    this.rating,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    const themeColor = Color.fromRGBO(255, 210, 50, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Name (uppercase, small, medium weight, grey)
          if (brandName != null) ...[
            Text(
              brandName!.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 4),
          ],
          // Product Name (xl to 2xl, medium weight, not bold)
          Text(
            productName,
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w500, // medium, not bold
            ),
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // Rating section removed - moved to image carousel overlay
        ],
      ),
    );
  }
}
