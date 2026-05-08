import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'combo_child_item.dart';

/// Combo Cart Item Widget
/// 
/// Renders a combo product with nested children with a premium design.
class ComboCartItem extends ConsumerWidget {
  final CartItem item;

  const ComboCartItem({
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
                  // Parent Product Row (Image + Name + Price)
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
                                  cacheWidth: 150,
                                  cacheHeight: 150,
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
  
                  // Combo Items Section: Nested children
                  if (item.comboItems != null && item.comboItems!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildComboItemsSection(item.comboItems!),
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

  /// Combo Items Section Widget
  Widget _buildComboItemsSection(List<dynamic> comboItems) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Includes:" label
          Row(
            children: [
              const Icon(
                Icons.inventory_2_rounded,
                size: 14,
                color: Color(0xFF4B5563),
              ),
              const SizedBox(width: 6),
              Text(
                'Includes:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Combo sub-items list
          ...comboItems.map((comboItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ComboChildItem(comboItem: comboItem),
            );
          }),
        ],
      ),
    );
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
