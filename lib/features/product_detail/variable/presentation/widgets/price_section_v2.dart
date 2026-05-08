import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../flash_sale/presentation/widgets/flash_sale_price_widget.dart';

/// Price section matching screenshot design
class PriceSectionV2 extends StatelessWidget {
  final double? salePrice;
  final double? regularPrice;
  final double? discountPercentage;
  final bool isFlashSale;
  final DateTime? flashSaleEndTime;

  const PriceSectionV2({
    super.key,
    this.salePrice,
    this.regularPrice,
    this.discountPercentage,
    this.isFlashSale = false,
    this.flashSaleEndTime,
  });

  @override
  Widget build(BuildContext context) {
    if (salePrice == null) {
      return const SizedBox.shrink();
    }

    if (isFlashSale && flashSaleEndTime != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: FlashSalePriceWidget(
          salePrice: salePrice!,
          regularPrice: regularPrice,
          endTime: flashSaleEndTime!,
          discountPercentage: discountPercentage,
        ),
      );
    }

    // Calculate saving amount
    final savingAmount = regularPrice != null && regularPrice! > salePrice!
        ? regularPrice! - salePrice!
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Sale Price (xl, bold weight)
              Text(
                '₹${salePrice!.toStringAsFixed(2)}',
                style: AppTextStyles.price.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Regular Price (strikethrough, xl, medium weight)
              if (regularPrice != null && regularPrice! > salePrice!) ...[
                const SizedBox(width: 12),
                Text(
                  '₹${regularPrice!.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey.shade700,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              // Discount Percentage (xl, medium weight, green)
              if (discountPercentage != null && discountPercentage! > 0) ...[
                const SizedBox(width: 12),
                Text(
                  '${discountPercentage!.toStringAsFixed(2)}% Off',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ],
            ],
          ),
          // Currently saving text
          if (savingAmount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Currently saving ₹${savingAmount.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.green.shade800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
