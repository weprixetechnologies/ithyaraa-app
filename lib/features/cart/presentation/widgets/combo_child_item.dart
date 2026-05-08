import 'package:flutter/material.dart';
import '../../../../features/order/domain/entities/combo_item.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Combo Child Item Widget
/// 
/// Renders a single combo sub-item with a premium design.
class ComboChildItem extends StatelessWidget {
  final ComboItemEntity comboItem;

  const ComboChildItem({
    super.key,
    required this.comboItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Combo sub-item image
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: comboItem.imageUrl != null
                ? Image.network(
                    comboItem.imageUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: 150,
                    cacheHeight: 150,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
        ),
        const SizedBox(width: 14),
        
        // Combo sub-item details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand name
              if (comboItem.brand != null && comboItem.brand!.isNotEmpty) ...[
                Text(
                  comboItem.brand!.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              
              // Product name
              Text(
                comboItem.name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF1F2937),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Variation Values
              if (comboItem.variationValues != null && comboItem.variationValues!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: comboItem.variationValues!.expand((variationMap) {
                    return variationMap.entries.map((entry) {
                      return Text(
                        '${entry.key}: ${entry.value}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    });
                  }).toList(),
                ),
              ]
              else if (comboItem.variationName != null && comboItem.variationName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  comboItem.variationName!.replaceAll('_', ' '),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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
        size: 20,
      ),
    );
  }
}
