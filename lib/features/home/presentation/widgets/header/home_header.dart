import 'package:flutter/material.dart';
import 'header_leading_menu_button.dart';
import 'header_logo.dart';
import 'header_actions.dart';

/// Home Header Widget - Main header for home page
///
/// PERFORMANCE OPTIMIZATION:
/// - Stateless widget - no state management in header itself
/// - Uses RepaintBoundary to prevent unnecessary repaints
/// - Cart and Wishlist badges are isolated Consumer widgets
/// - Header does NOT rebuild when:
///   - Cart count changes (handled by CartIconWithBadge)
///   - Wishlist count changes (handled by WishlistIconWithBadge)
///
/// LAYOUT:
/// - Hamburger menu (left)
/// - App logo (center)
/// - Search, Wishlist, Cart buttons (right)
///
/// EDGE-TO-EDGE:
/// - Extends behind status bar with transparent status bar
/// - topPadding accounts for status bar height to prevent icon overlap
class HomeHeader extends StatelessWidget {
  final VoidCallback? onSearchPressed;
  final VoidCallback? onWishlistPressed;
  final VoidCallback? onCartPressed;
  final double topPadding;

  const HomeHeader({
    super.key,
    this.onSearchPressed,
    this.onWishlistPressed,
    this.onCartPressed,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.only(
          top: topPadding + 12,
          bottom: 12,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Row(
          children: [
            const HeaderLeadingMenuButton(),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: const HeaderLogo(),
              ),
            ),
            const SizedBox(width: 16),
            HeaderActions(
              onSearchPressed: onSearchPressed,
              onWishlistPressed: onWishlistPressed,
              onCartPressed: onCartPressed,
            ),
          ],
        ),
      ),
    );
  }
}
