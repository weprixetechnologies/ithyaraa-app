import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Stock status widget
class StockStatus extends StatelessWidget {
  final bool inStock;
  final int? stockQuantity;

  const StockStatus({
    super.key,
    required this.inStock,
    this.stockQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            inStock ? Icons.check_circle : Icons.cancel,
            color: inStock ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            inStock ? 'In Stock' : 'Out of Stock',
            style: AppTextStyles.bodyMedium.copyWith(
              color: inStock ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (inStock && stockQuantity != null && stockQuantity! > 0) ...[
            const SizedBox(width: 8),
            Text(
              '($stockQuantity available)',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
