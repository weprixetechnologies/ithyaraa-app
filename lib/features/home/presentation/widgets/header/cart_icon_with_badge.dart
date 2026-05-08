import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/cart/presentation/providers/cart_provider.dart';

/// Isolated Cart Icon with Badge widget
///
/// PERFORMANCE OPTIMIZATION:
/// - Uses Consumer with select() to listen ONLY to cart count
/// - This widget rebuilds ONLY when cart count changes
/// - Parent HomeHeader does NOT rebuild when cart count changes
/// - Badge animates smoothly on count change
/// - Badge hides when count = 0
class CartIconWithBadge extends ConsumerWidget {
  final VoidCallback? onPressed;

  const CartIconWithBadge({super.key, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CRITICAL: Using select() to listen ONLY to cart itemCount
    // This prevents parent rebuilds when other cart state changes
    final cartItemCount = ref.watch(
      cartControllerProvider.select((state) => state.cartState?.itemCount ?? 0),
    );

    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: GestureDetector(
              onTap: onPressed,
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 26,
                color: Colors.black87,
              ),
            ),
          ),
          // Badge only shows when count > 0
          if (cartItemCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey(cartItemCount),
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
