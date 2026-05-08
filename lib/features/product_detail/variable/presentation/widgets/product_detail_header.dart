import 'package:flutter/material.dart';

/// Product detail page header with action icons
class ProductDetailHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onWalletTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onCartTap;
  final bool isWishlisted;

  const ProductDetailHeader({
    super.key,
    this.onBackPressed,
    this.onWalletTap,
    this.onShareTap,
    this.onWishlistTap,
    this.onCartTap,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            color: Colors.black87,
          ),
          // Action icons
          Row(
            children: [
              // Wallet/Points icon
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 20,
                    color: Colors.amber.shade800,
                  ),
                ),
                onPressed: onWalletTap,
                color: Colors.black87,
              ),
              // Share icon
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: onShareTap,
                color: Colors.black87,
              ),
              // Wishlist icon
              IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : Colors.black87,
                ),
                onPressed: onWishlistTap,
                color: Colors.black87,
              ),
              // Cart icon
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: onCartTap,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
