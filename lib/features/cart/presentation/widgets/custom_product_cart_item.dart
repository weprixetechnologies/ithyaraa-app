import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom Product Cart Item Widget
/// 
/// Renders a custom product with user-provided custom inputs with a premium design.
class CustomProductCartItem extends ConsumerWidget {
  final CartItem item;

  const CustomProductCartItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemTotal = item.lineTotalAfter ?? item.salePrice ?? item.regularPrice ?? 0.0;

    final isFlash = item.isFlashSale == 1;

    return Opacity(
      opacity: item.isAvailable ? 1.0 : 0.6,
      child: Container(
        margin: isFlash ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isFlash ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isFlash ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: item.imageUrl != null
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                                )
                              : _buildPlaceholderImage(),
                        ),
                      ),
                      const SizedBox(width: 16),
  
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              item.name,
                              style: AppTextStyles.headingSmall.copyWith(
                                fontSize: 15,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
  
                            // Stock Status Badge
                            if (!item.isAvailable)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.stockStatus == 'out_of_stock'
                                        ? Colors.red.shade50
                                        : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: item.stockStatus == 'out_of_stock'
                                          ? Colors.red.shade100
                                          : Colors.amber.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    item.stockStatus == 'out_of_stock'
                                        ? 'Out of Stock'
                                        : 'Low Stock: ${item.variationStock} Left',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: item.stockStatus == 'out_of_stock'
                                          ? Colors.red.shade700
                                          : Colors.amber.shade900,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
  
                            // Price and Quantity Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${itemTotal.toStringAsFixed(0)}',
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F1F2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Qty: ${item.quantity}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Colors.blueGrey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
  
                  // Custom Inputs Section: User-provided custom data
                  if (item.customInputs != null && item.customInputs!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildCustomInputsSection(item.customInputs!),
                  ],
                ],
              ),
            ),
            
            // Selection Checkbox (Top Left)
            Positioned(
              top: 2,
              left: 2,
              child: Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: ref.watch(cartControllerProvider.select(
                    (s) => s.localSelectedItems?.contains(item.cartItemID) ?? false,
                  )),
                  activeColor: const Color(0xFFFFD232),
                  checkColor: Colors.black,
                  shape: const CircleBorder(),
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  onChanged: (selected) {
                    ref.read(cartControllerProvider.notifier).updateLocalSelection(
                          item.cartItemID,
                          selected ?? false,
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom Inputs Section Widget
  Widget _buildCustomInputsSection(Map<String, dynamic> customInputs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEDD5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Custom Details:" label
          Row(
            children: [
              const Icon(
                Icons.mode_edit_outline_rounded,
                size: 14,
                color: Color(0xFFC2410C),
              ),
              const SizedBox(width: 6),
              Text(
                'Custom Details:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC2410C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Render each custom input
          ...customInputs.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;
            return _buildCustomInputItem(key, value);
          }),
        ],
      ),
    );
  }

  /// Custom Input Item Widget
  Widget _buildCustomInputItem(String key, dynamic value) {
    // Check if value is an image URL
    final isImage = _isImageUrl(value?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key label
          Text(
            key.replaceAll('_', ' ').toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF9A3412),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Value: image or text
          if (isImage)
            // Image preview
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  value.toString(),
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  cacheWidth: 200,
                  cacheHeight: 200,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                ),
              ),
            )
          else
            // Text value
            Text(
              value?.toString() ?? '',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF431407),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  /// Helper: Check if a string is an image URL
  bool _isImageUrl(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('customer-upload') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.endsWith('.gif') ||
        lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.webp') ||
        lowerUrl.contains('.gif');
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }
}
