import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import 'wishlist_button.dart';
import 'rating_badge.dart';
import 'combo_product_card.dart';
import 'make_combo_product_card.dart';
import 'custom_product_card.dart';

/// Product card entry widget for the shop grid.
/// Delegates to specific card widgets based on product.type.
class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = product.type;

    // Type-based card selection
    switch (type) {
      case 'combo':
        return ComboProductCard(product: product);
      case 'make_combo':
        return MakeComboProductCard(product: product);
      case 'customproduct':
        return CustomProductCard(product: product);
      default:
        // Fallback to existing variable/default product card behavior
        return _DefaultProductCard(
          product: product,
          onTap: onTap,
          onWishlistTap: onWishlistTap,
        );
    }
  }
}

/// Existing variable/default product card implementation (unchanged behavior)
class _DefaultProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  const _DefaultProductCard({
    required this.product,
    this.onTap,
    this.onWishlistTap,
  });

  String? get _imageUrl {
    if (product.featuredImages.isEmpty) return null;
    return product.featuredImages.first.imgUrl;
  }

  String? get _brandName {
    // Use product.brand if available
    return product.brand;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate aspect ratio: 170 / 222 ≈ 0.7658
    const imageAspectRatio = 170 / 222;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image with Overlays (170:222 aspect ratio)
            AspectRatio(
              aspectRatio: imageAspectRatio,
              child: Stack(
                children: [
                  // Product Image with rounded corners
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
                  // Rating Badge (bottom-left inside image)
                  // Using 8dp grid system for positioning
                  if (product.rating != null)
                    Positioned(
                      left: 8, // 8dp from left
                      bottom: 8, // 8dp from bottom
                      child: RatingBadge(
                        rating: product.rating!,
                        reviewCount: product.reviewCount,
                      ),
                    ),
                  // Wishlist Button (top-right inside image)
                  // Using 8dp grid system for positioning
                  Positioned(
                    top: 8, // 8dp from top
                    right: 8, // 8dp from right
                    child: WishlistButton(product: product),
                  ),
                  // Flash Sale Badge (top-left inside image)
                  if (product.isFlashSale == true)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'FLASH',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Brand Name and Product Name Column
            // Using 8dp grid system for consistent spacing
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Name (optional, single line, 10px - secondary info)
                  // if (_brandName != null) ...[
                  //   Text(
                  //     _brandName!,
                  //     style: AppTextStyles.bodySmall.copyWith(
                  //       color: Colors.grey.shade600,
                  //       fontSize: 10,
                  //       fontWeight:
                  //           FontWeight.w400, // Regular weight for secondary
                  //       height: 1, // Line height for readability
                  //     ),
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  //   const SizedBox(height: 4), // 4dp spacing (half of 8dp grid)
                  // ],
                  // Product Name (1 line, 14px - primary info)
                  Text(
                    product.productName,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600, // Medium weight for emphasis
                      height: 1.4, // Comfortable line spacing
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Price Row - Clear visual hierarchy
            Padding(
              padding: const EdgeInsets.only(
                top: 2,
              ), // 8dp spacing (grid system)
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Sale Price - Primary emphasis (green, semi-bold)
                  if (product.salePrice != null)
                    Text(
                      '₹${product.salePrice!.toStringAsFixed(0)}',
                      style: AppTextStyles.price.copyWith(
                        color: Colors.green.shade700, // Better contrast
                        fontWeight: FontWeight.w600, // Semi-bold for emphasis
                        fontSize: 16, // Slightly larger for hierarchy
                      ),
                    ),
                  // Regular Price (struck-through) - Secondary info
                  if (product.regularPrice != null &&
                      product.salePrice != null) ...[
                    const SizedBox(width: 8), // 8dp spacing
                    Text(
                      '₹${product.regularPrice!.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade600,
                        fontSize: 12, // Smaller for secondary info
                        fontWeight: FontWeight.w400, // Regular weight
                      ),
                    ),
                  ],
                  // Discount Percentage (inline) - Accent color
                  if (product.discountPercentage != null &&
                      product.discountPercentage! > 0) ...[
                    const SizedBox(width: 8), // 8dp spacing
                    Text(
                      '${product.discountPercentage!.toStringAsFixed(0)}% OFF',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.w600, // Semi-bold for emphasis
                        fontSize: 11, // Compact but readable
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
