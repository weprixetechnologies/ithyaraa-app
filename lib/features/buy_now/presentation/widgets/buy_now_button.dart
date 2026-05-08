import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'buy_now_bottom_sheet.dart';
import '../state/buy_now_state.dart';

class BuyNowButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final String label;
  final BuyNowState initialState;
  final bool Function()? onBeforeBuy;

  const BuyNowButton({
    super.key,
    required this.isEnabled,
    this.isLoading = false,
    this.label = 'Buy Now',
    required this.initialState,
    this.onBeforeBuy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading
            ? () {
                if (onBeforeBuy != null && !onBeforeBuy!()) return;
                BuyNowBottomSheet.show(context, initialState);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: isEnabled ? Colors.white : Colors.grey.shade600,
                ),
              ),
      ),
    );
  }
}
