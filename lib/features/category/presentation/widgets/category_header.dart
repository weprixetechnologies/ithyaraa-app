import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Category page header widget
///
/// EDGE-TO-EDGE:
/// - Extends behind status bar with transparent status bar
/// - topPadding accounts for status bar height to prevent icon overlap
class CategoryHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onCartPressed;
  final double topPadding;

  const CategoryHeader({
    super.key,
    this.onBackPressed,
    this.onSearchPressed,
    this.onCartPressed,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFD232),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back),
            color: Colors.black87,
          ),
          // Title
          Text(
            'Categories',
            style: AppTextStyles.headingMedium,
          ),
          const Spacer(),
          // Search Icon
          IconButton(
            onPressed: onSearchPressed,
            icon: const Icon(Icons.search),
            color: Colors.black87,
          ),
          // Cart Icon
          IconButton(
            onPressed: onCartPressed,
            icon: const Icon(Icons.shopping_cart_outlined),
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
