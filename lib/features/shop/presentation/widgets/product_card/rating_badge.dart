import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Rating badge widget displayed over product image
class RatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final Color? backgroundColor;
  final Color? textColor;

  const RatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = backgroundColor ?? Colors.white;
    final defaultTextColor = textColor ?? Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodySmall.copyWith(
              color: defaultTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (reviewCount != null) ...[
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: AppTextStyles.caption.copyWith(
                color: defaultTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
