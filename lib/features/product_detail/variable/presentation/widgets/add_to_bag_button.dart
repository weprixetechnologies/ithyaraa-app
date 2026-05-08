import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Add to bag button (yellow, prominent CTA)
class AddToBagButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isEnabled;
  final String? text;

  const AddToBagButton({
    super.key,
    this.onTap,
    this.isEnabled = true,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text ?? 'ADD TO BAG',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
