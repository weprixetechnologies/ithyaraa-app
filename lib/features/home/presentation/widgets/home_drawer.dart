import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../order/presentation/pages/order_history_page.dart';
import '../../../presale/presentation/pages/presale_order_history_page.dart';
import '../../../navigation/presentation/providers/navigation_provider.dart';
import 'drawer/drawer_profile_section.dart';
import 'drawer/drawer_primary_nav_section.dart';
import 'drawer/drawer_secondary_nav_section.dart';
import 'drawer/drawer_quick_actions_section.dart';
import 'drawer/drawer_footer_section.dart';
import 'drawer/drawer_nav_item.dart';

/// Home Drawer - Left side drawer opened by hamburger menu
/// 
/// PERFORMANCE OPTIMIZATION:
/// - Uses ListView for vertical scrolling
/// - Each section is isolated - only profile and footer watch auth state
/// - Primary nav, secondary nav, and quick actions are stateless
/// - Rebuilds are minimized - only profile/footer rebuild on auth change
class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  void _handleNavigation(
    BuildContext context,
    bool isLoggedIn,
    VoidCallback? authenticatedRoute,
    VoidCallback? unauthenticatedRoute,
  ) {
    Navigator.pop(context); // Close drawer first
    if (!isLoggedIn && unauthenticatedRoute != null) {
      unauthenticatedRoute();
    } else if (isLoggedIn && authenticatedRoute != null) {
      authenticatedRoute();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read auth state once for navigation logic (not watching)
    final authState = ref.read(authProvider);

    // Primary navigation items (data-driven)
    final primaryNavItems = [
      DrawerNavItem(
        icon: Icons.home,
        label: 'Home',
        onTap: () {
          Navigator.pop(context);
          // Navigate to home page in bottom navigation
          ref.read(navigationProvider.notifier).setIndex(0);
        },
      ),
      DrawerNavItem(
        icon: Icons.category,
        label: 'Categories',
        onTap: () {
          Navigator.pop(context);
          // Navigate to categories page in bottom navigation (IndexedStack)
          ref.read(navigationProvider.notifier).setIndex(1);
        },
      ),
      DrawerNavItem(
        icon: Icons.shopping_cart,
        label: 'Cart',
        requiresAuth: true,
        onTap: () => _handleNavigation(
          context,
          authState.isLoggedIn,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
      DrawerNavItem(
        icon: Icons.favorite,
        label: 'Wishlist',
        requiresAuth: true,
        onTap: () => _handleNavigation(
          context,
          authState.isLoggedIn,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistPage()),
            );
          },
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
      DrawerNavItem(
        icon: Icons.receipt_long,
        label: 'Orders',
        requiresAuth: true,
        onTap: () => _handleNavigation(
          context,
          authState.isLoggedIn,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
            );
          },
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
      DrawerNavItem(
        icon: Icons.history_edu,
        label: 'Pre-Booked History',
        requiresAuth: true,
        onTap: () => _handleNavigation(
          context,
          authState.isLoggedIn,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PresaleOrderHistoryPage()),
            );
          },
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
      DrawerNavItem(
        icon: Icons.person,
        label: 'Profile',
        requiresAuth: true,
        onTap: () => _handleNavigation(
          context,
          authState.isLoggedIn,
          () {
            // Navigate to profile page in bottom navigation (IndexedStack)
            ref.read(navigationProvider.notifier).setIndex(2);
          },
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
    ];

    // Secondary navigation items (data-driven)
    final secondaryNavItems = [
      DrawerNavItem(
        icon: Icons.help_outline,
        label: 'Help Center',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to help center
        },
      ),
      DrawerNavItem(
        icon: Icons.support_agent,
        label: 'Support',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to support
        },
      ),
      DrawerNavItem(
        icon: Icons.info_outline,
        label: 'About',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to about
        },
      ),
    ];

    // Quick actions (data-driven)
    final quickActions = [
      DrawerQuickAction(
        icon: Icons.local_offer,
        label: 'Offers',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to offers
        },
      ),
      DrawerQuickAction(
        icon: Icons.card_giftcard,
        label: 'Gift Cards',
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to gift cards
        },
      ),
      DrawerQuickAction(
        icon: Icons.star_outline,
        label: 'Rate Us',
        onTap: () {
          Navigator.pop(context);
          // TODO: Open app store rating
        },
      ),
      DrawerQuickAction(
        icon: Icons.share,
        label: 'Share App',
        onTap: () {
          Navigator.pop(context);
          // TODO: Share app
        },
      ),
    ];

    // Footer sections (data-driven)
    final footerSections = [
      DrawerFooterSectionModel(
        title: 'Legal',
        items: [
          DrawerFooterItem(
            label: 'Terms & Conditions',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to terms
            },
          ),
          DrawerFooterItem(
            label: 'Privacy Policy',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to privacy
            },
          ),
        ],
      ),
      DrawerFooterSectionModel(
        title: 'App',
        items: [
          DrawerFooterItem(
            label: 'Version 1.0.0',
            onTap: null, // Not tappable
          ),
          DrawerFooterItem(
            label: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
    ];

    return Drawer(
      child: SafeArea(
        child: ListView(
          // Remove padding to allow sections to control their own padding
          padding: EdgeInsets.zero,
          children: [
            // Profile Section - watches auth state
            const DrawerProfileSection(),
            // Primary Navigation - stateless
            DrawerPrimaryNavSection(items: primaryNavItems),
            // Divider
            const Divider(height: 1),
            // Secondary Navigation - stateless
            DrawerSecondaryNavSection(items: secondaryNavItems),
            // Quick Actions - stateless
            DrawerQuickActionsSection(actions: quickActions),
            // Footer Section - watches auth state
            DrawerFooterSection(
              sections: footerSections,
              onLoginTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              onLogoutTap: () async {
                Navigator.pop(context);
                // Logout logic handled by auth provider
                await ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
