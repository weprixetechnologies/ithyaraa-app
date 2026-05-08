import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Offer banner widget displaying coupon strip
class OfferBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const OfferBanner({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withValues(alpha: 0.1),
            const Color(0xFFE91E63).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE91E63).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: const Color(0xFFE91E63),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Special Offers Available',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFFE91E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFFE91E63),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
