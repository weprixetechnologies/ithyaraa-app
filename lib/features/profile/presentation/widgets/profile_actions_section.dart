import 'package:flutter/material.dart';
import 'profile_action_tile.dart';

/// Section containing all profile action tiles
///
/// Actions:
/// - Orders
/// - Help Center
/// - Wishlist
/// - Scan for coupon
class ProfileActionsSection extends StatelessWidget {
  final VoidCallback? onOrdersTap;
  final VoidCallback? onPreBookedTap;
  final VoidCallback? onHelpCenterTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onScanCouponTap;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onReturnsTap;

  const ProfileActionsSection({
    super.key,
    this.onOrdersTap,
    this.onPreBookedTap,
    this.onHelpCenterTap,
    this.onWishlistTap,
    this.onScanCouponTap,
    this.onCoinsTap,
    this.onReturnsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ProfileActionTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            subtitle: 'Check your order status',
            onTap: onOrdersTap,
          ),
          const Divider(height: 1, indent: 64),
          ProfileActionTile(
            icon: Icons.history_edu_outlined,
            title: 'Pre-Booked History',
            subtitle: 'Track your presale bookings',
            onTap: onPreBookedTap,
          ),
          const Divider(height: 1, indent: 64),
          ProfileActionTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Help regarding your recent purchases',
            onTap: onHelpCenterTap,
          ),
          const Divider(height: 1, indent: 64),
          ProfileActionTile(
            icon: Icons.stars_outlined,
            title: 'Ithyaraa Coins',
            subtitle: 'Redeem coins to wallet',
            onTap: onCoinsTap,
          ),
          const Divider(height: 1, indent: 64),
          ProfileActionTile(
            icon: Icons.assignment_return_outlined,
            title: 'Return History',
            subtitle: 'Track your returns & refunds',
            onTap: onReturnsTap,
          ),
          const Divider(height: 1, indent: 64),
          ProfileActionTile(
            icon: Icons.favorite_border,
            title: 'Wishlist',
            subtitle: 'Your most loved products',
            onTap: onWishlistTap,
          ),
          const Divider(height: 1, indent: 64),
          ProfileActionTile(
            icon: Icons.qr_code_scanner,
            title: 'Scan for coupon',
            subtitle: '',
            onTap: onScanCouponTap,
          ),
        ],
      ),
    );
  }
}
