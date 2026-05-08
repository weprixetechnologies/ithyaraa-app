import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

/// Optimized Cart Item Checkbox
/// 
/// Handles checkbox selection with minimal rebuilds.
/// Uses selectors to watch only selected items list, not entire cart state.
class CartItemCheckbox extends ConsumerWidget {
  final bool isSelected;
  final String cartItemID;

  const CartItemCheckbox({
    super.key,
    required this.isSelected,
    required this.cartItemID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Checkbox(
      value: isSelected,
      onChanged: (selected) {
        // Update selection locally
        ref.read(cartControllerProvider.notifier).updateLocalSelection(
              cartItemID,
              selected ?? false,
            );
      },
    );
  }
}
