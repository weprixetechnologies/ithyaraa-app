import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/cross_sell_product.dart';

/// Cross-sell products section
class CrossSellSection extends StatelessWidget {
  final List<CrossSellProductEntity> crossSellProducts;
  final Function(CrossSellProductEntity)? onProductTap;

  const CrossSellSection({
    super.key,
    required this.crossSellProducts,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (crossSellProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            'You may also like',
            style: AppTextStyles.headingSmall,
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: crossSellProducts.length,
            itemBuilder: (context, index) {
              final product = crossSellProducts[index];

              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    if (onProductTap != null) {
                      onProductTap!(product);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!,
                                width: 160,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 160,
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              )
                            : Container(
                                width: 160,
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported),
                              ),
                      ),
                      const SizedBox(height: 8),
                      // Product Name
                      Text(
                        product.productName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Price
                      if (product.salePrice != null)
                        Text(
                          '₹${product.salePrice!.toStringAsFixed(0)}',
                          style: AppTextStyles.price.copyWith(
                            color: Colors.green.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
