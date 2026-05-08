import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/wishlist/presentation/providers/wishlist_provider.dart';

/// Isolated Wishlist Icon with Badge widget
///
/// PERFORMANCE OPTIMIZATION:
/// - Uses Consumer with select() to listen ONLY to wishlist item count
/// - This widget rebuilds ONLY when wishlist count changes
/// - Parent HomeHeader does NOT rebuild when wishlist count changes
/// - Badge animates smoothly on count change
/// - Badge hides when count = 0
class WishlistIconWithBadge extends ConsumerWidget {
  final VoidCallback? onPressed;

  const WishlistIconWithBadge({super.key, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CRITICAL: Using select() to listen ONLY to wishlist items length
    // This prevents parent rebuilds when other wishlist state changes
    final wishlistItemCount = ref.watch(
      wishlistProvider.select((state) => state.items.length),
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
                Icons.favorite_outline_rounded,
                size: 26,
                color: Colors.black87,
              ),
            ),
          ),
          // Badge only shows when count > 0
          if (wishlistItemCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey(wishlistItemCount),
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
                    wishlistItemCount > 99
                        ? '99+'
                        : wishlistItemCount.toString(),
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
