import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import 'wishlist_button.dart';
import '../../../../product_detail/combo/presentation/pages/combo_product_pdp.dart';

/// Combo product card aligned with the variable product card style
class ComboProductCard extends StatelessWidget {
  final ProductEntity product;

  const ComboProductCard({super.key, required this.product});

  String? get _imageUrl {
    if (product.featuredImages.isEmpty) return null;
    return product.featuredImages.first.imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    // Maintain same aspect ratio as variable product card: 170 / 222
    const imageAspectRatio = 170 / 222;

    return Card(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to Combo PDP with productID only (matches Variable PDP pattern)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComboProductPDP(productID: product.productID),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Featured Image with wishlist overlay
            AspectRatio(
              aspectRatio: imageAspectRatio,
              child: Stack(
                children: [
                  // Product Image with rounded corners and placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  // Wishlist Button (top-right inside image) - same as variable card
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishlistButton(product: product),
                  ),
                ],
              ),
            ),
            // Product Name
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                product.productName,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500, // Semibold / medium
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Pricing Section - exactly matches variable product card
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Sale Price
                  if (product.salePrice != null)
                    Text(
                      '₹${product.salePrice!.toStringAsFixed(0)}',
                      style: AppTextStyles.price.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  // Regular Price (struck-through)
                  if (product.regularPrice != null &&
                      product.salePrice != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '₹${product.regularPrice!.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  // Discount Percentage
                  if (product.discountPercentage != null &&
                      product.discountPercentage! > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${product.discountPercentage!.toStringAsFixed(0)}% OFF',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
