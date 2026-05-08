import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import '../../../../product_detail/custom/presentation/pages/custom_product_pdp.dart';
import 'wishlist_button.dart';
import 'rating_badge.dart';

/// Product card for type "customproduct".
/// Matches the layout and component structure of the default [_DefaultProductCard],
/// with an added "Custom" badge to distinguish made-to-order products.
class CustomProductCard extends StatelessWidget {
  final ProductEntity product;

  const CustomProductCard({super.key, required this.product});

  String? get _imageUrl {
    if (product.featuredImages.isEmpty) return null;
    return product.featuredImages.first.imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    // Same 170:222 aspect ratio used by the default card
    const imageAspectRatio = 170 / 222;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomProductPDP(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Product Image with Overlays ──────────────────────────────────
            AspectRatio(
              aspectRatio: imageAspectRatio,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            },
                          )
                        : _imagePlaceholder(),
                  ),

                  // ── Custom badge — top-left ──────────────────────────────
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD232),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Custom',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          height: 1,
                        ),
                      ),
                    ),
                  ),

                  // ── Rating Badge — bottom-left ───────────────────────────
                  if (product.rating != null)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: RatingBadge(
                        rating: product.rating!,
                        reviewCount: product.reviewCount,
                      ),
                    ),

                  // ── Wishlist Button — top-right ──────────────────────────
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishlistButton(product: product),
                  ),
                ],
              ),
            ),

            // ── Product Name ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                product.productName,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Price Row ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Sale / starting price
                  if (product.salePrice != null)
                    Text(
                      '₹${product.salePrice!.toStringAsFixed(0)}',
                      style: AppTextStyles.price.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  // Struck-through regular price
                  if (product.regularPrice != null && product.salePrice != null) ...[
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
                  // Discount %
                  if (product.discountPercentage != null && product.discountPercentage! > 0) ...[
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

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.palette_outlined, color: Colors.grey.shade400, size: 28),
            const SizedBox(height: 4),
            Text(
              'Custom',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
