import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithyaraaapp/features/cart/presentation/widgets/add_to_cart_button.dart';
import 'package:ithyaraaapp/features/buy_now/presentation/widgets/buy_now_button.dart';
import 'package:ithyaraaapp/features/buy_now/presentation/state/buy_now_state.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/quantity_selector.dart';

/// Action buttons section with quantity selector, Add to Cart, and Buy Now
class ActionButtonsSection extends ConsumerWidget {
  final String productID;
  final int quantity;
  final Function(int) onQuantityChanged;
  final String? variationID;
  final String? variationName;
  final String? referBy;
  final Map<String, dynamic>? customInputs;
  final Map<String, dynamic>? selectedDressType;
  final VoidCallback? onAddToCartSuccess;
  final bool isEnabled;
  final bool hasVariations;
  final Function(String)? onValidationError;
  final bool Function()? onValidate;
  
  // New fields for Buy Now initialization
  final String? productName;
  final String? productImage;
  final double salePrice;
  final double regularPrice;
  final String productType;

  const ActionButtonsSection({
    super.key,
    required this.productID,
    required this.quantity,
    required this.onQuantityChanged,
    this.variationID,
    this.variationName,
    this.referBy,
    this.customInputs,
    this.selectedDressType,
    this.onAddToCartSuccess,
    this.isEnabled = true,
    this.hasVariations = false,
    this.onValidationError,
    this.onValidate,
    this.productName,
    this.productImage,
    required this.salePrice,
    required this.regularPrice,
    this.productType = 'variable',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity Selector Row - Hidden if variations are required but not yet selected
          if (!hasVariations || variationID != null) ...[
            Row(
              children: [
                Text(
                  'Quantity :',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuantitySelector(
                    quantity: quantity,
                    onQuantityChanged: onQuantityChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Buttons Row
          Row(
            children: [
              // Add to Cart
              Expanded(
                child: AddToCartButton(
                  productID: productID,
                  quantity: quantity,
                  variationID: variationID,
                  variationName: variationName,
                  referBy: referBy,
                  customInputs: customInputs,
                  selectedDressType: selectedDressType,
                  onSuccess: onAddToCartSuccess,
                  isEnabled: isEnabled,
                  onBeforeAdd: () {
                    if (onValidate != null && !onValidate!()) return false;
                    if (hasVariations && variationID == null) {
                      if (onValidationError != null) {
                        onValidationError!('Please select a variation before adding to cart');
                      }
                      return false;
                    }
                    return true;
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Buy Now
              Expanded(
                child: BuyNowButton(
                  isEnabled: isEnabled,
                  onBeforeBuy: () {
                    if (onValidate != null && !onValidate!()) return false;
                    if (hasVariations && variationID == null) {
                      if (onValidationError != null) {
                        onValidationError!('Please select a variation before placing order');
                      }
                      return false;
                    }
                    return true;
                  },
                  initialState: BuyNowState(
                    productType: productType,
                    productID: productID,
                    variationID: variationID,
                    quantity: quantity,
                    customInputs: customInputs,
                    selectedDressType: selectedDressType,
                    productName: productName,
                    productImage: productImage,
                    salePrice: salePrice,
                    regularPrice: regularPrice,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
