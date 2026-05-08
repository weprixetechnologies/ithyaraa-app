import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/presale_product.dart';
import '../../../shop/presentation/widgets/product_card/wishlist_button.dart';
import 'presale_countdown_timer.dart';

class PresaleProductCard extends StatelessWidget {
  final PresaleProductEntity product;
  final VoidCallback? onTap;

  const PresaleProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  String? get _imageUrl {
    if (product.featuredImages.isEmpty) return null;
    return product.featuredImages.first.imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    const imageAspectRatio = 170 / 222;
    final isUpcoming = product.isUpcoming;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            AspectRatio(
              aspectRatio: imageAspectRatio,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey.shade200),
                  ),
                  // Upcoming Badge
                  if (isUpcoming)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'UPCOMING',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Wishlist
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishlistButton(product: product),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (product.regularPrice != null)
                        Text(
                          '₹${product.regularPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        '₹${product.salePrice!.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  if (product.discountPercentage != null)
                    Text(
                      '(${product.discountPercentage!.toStringAsFixed(0)}% OFF)',
                      style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 4),
                  // Countdown
                  if (product.preSaleEndDate != null || product.preSaleStartDate != null)
                    PresaleCountdownTimer(
                      endTime: isUpcoming ? product.preSaleStartDate! : product.preSaleEndDate!,
                      label: isUpcoming ? 'STARTS IN' : 'ENDS IN',
                    ),
                  const SizedBox(height: 6),
                  // Action Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isUpcoming ? Colors.grey.shade300 : const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        isUpcoming ? 'COMING SOON' : 'BUY NOW',
                        style: TextStyle(
                          color: isUpcoming ? Colors.grey.shade600 : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
