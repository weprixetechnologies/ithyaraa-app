import 'package:flutter/material.dart';
import '../../domain/entities/cart_item.dart';
import 'variable_cart_item.dart';
import 'combo_cart_item.dart';
import 'make_combo_cart_item.dart';
import 'custom_product_cart_item.dart';
import 'flash_sale_cart_item_wrapper.dart';

/// Cart Item Renderer
/// 
/// Switches rendering based on productType to match Order Detail Page hierarchy:
/// - variable → VariableCartItem
/// - combo → ComboCartItem
/// - make_combo → MakeComboCartItem
/// - customproduct → CustomProductCartItem
/// - fallback → VariableCartItem (for simple/unknown types)
/// 
/// OPTIMIZED: Changed from ConsumerWidget to StatelessWidget
/// - No provider watching needed (only reads item.productType)
/// - Prevents unnecessary rebuilds when unrelated providers change
class CartItemRenderer extends StatelessWidget {
  final CartItem item;

  const CartItemRenderer({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final productType = item.productType?.toLowerCase() ?? 'variable';

    Widget child;
    switch (productType) {
      case 'variable':
        child = VariableCartItem(item: item);
        break;
      case 'combo':
        child = ComboCartItem(item: item);
        break;
      case 'make_combo':
        child = MakeComboCartItem(item: item);
        break;
      case 'customproduct':
        child = CustomProductCartItem(item: item);
        break;
      default:
        // Fallback to variable for unknown types
        child = VariableCartItem(item: item);
    }

    return FlashSaleCartItemWrapper(
      isFlashSale: item.isFlashSale == 1,
      child: child,
    );
  }
}
