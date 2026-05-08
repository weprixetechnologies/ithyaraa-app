import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Add to cart button widget
/// Uses provider.family(productID) for isolated state per product
class AddToCartButton extends ConsumerWidget {
  final String productID;
  final int quantity;
  final String? variationID;
  final String? variationName;
  final String? referBy;
  final Map<String, dynamic>? customInputs;
  final Map<String, dynamic>? selectedDressType;
  final VoidCallback? onSuccess;
  final bool isEnabled;
  final bool Function()? onBeforeAdd;

  const AddToCartButton({
    super.key,
    required this.productID,
    this.quantity = 1,
    this.variationID,
    this.variationName,
    this.referBy,
    this.customInputs,
    this.selectedDressType,
    this.onSuccess,
    this.isEnabled = true,
    this.onBeforeAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only isLoading state
    final isLoading = ref.watch(
      addToCartButtonProvider(productID).select((state) => state.isLoading),
    );

    final controller = ref.read(addToCartButtonProvider(productID).notifier);

    // Exact premium theme color
    const themeColor = Color(0xFFFFD232);
    
    return ElevatedButton(
      onPressed: isEnabled && !isLoading
          ? () async {
              if (onBeforeAdd != null && !onBeforeAdd!()) {
                return;
              }

              await controller.addToCart(
                quantity: quantity,
                variationID: variationID,
                variationName: variationName,
                referBy: referBy,
                customInputs: customInputs,
                selectedDressType: selectedDressType,
              );

              Future.delayed(const Duration(milliseconds: 100), () {
                final state = ref.read(addToCartButtonProvider(productID));
                if (state.isSuccess && onSuccess != null) {
                  onSuccess!();
                }
              });
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColor,
        foregroundColor: Colors.black,
        disabledBackgroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: isEnabled && !isLoading ? 2 : 0,
        shadowColor: themeColor.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(double.infinity, 54),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : Text(
              'Add to Cart',
              style: AppTextStyles.button.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
    );
  }
}
