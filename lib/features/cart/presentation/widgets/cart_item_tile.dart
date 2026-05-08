import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';
import 'cart_item_renderer.dart';

/// Cart item tile widget
///
/// Delegates to CartItemRenderer which switches rendering based on productType.
/// This ensures hierarchy matches Order Detail Page structure.
///
/// Isolated widget that rebuilds only itself.
/// UPDATED: Wrapped in Dismissible to support "Swipe to Delete" (End to Start).
class CartItemTile extends ConsumerWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine if it's a flash sale item for visual spacing in dismissible background
    final isFlash = item.isFlashSale == 1;

    return Dismissible(
      key: ValueKey('cart_dismissible_${item.cartItemID}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        ref.read(cartControllerProvider.notifier).removeItem(item.cartItemID);
      },
      // Sliding background (red container with trash icon)
      secondaryBackground: Container(
        margin: isFlash
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      // Empty left background since we only allow endToStart (slide left)
      background: Container(color: Colors.transparent),
      child: CartItemRenderer(item: item),
    );
  }
}
