import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Product title section (brand name + product name)
class ProductTitleSection extends StatelessWidget {
  final String? brandName;
  final String productName;

  const ProductTitleSection({
    super.key,
    this.brandName,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              ),
            ),
            const SizedBox(height: 4),
          ],
          // Product Name
          Text(
            productName,
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 20,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
