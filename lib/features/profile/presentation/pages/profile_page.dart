import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_actions_section.dart';
import '../widgets/profile_footer_links.dart';
import '../state/profile_provider.dart';
import 'edit_profile_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../order/presentation/pages/order_history_page.dart';
import '../../../presale/presentation/pages/presale_order_history_page.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'coins_page.dart';
import 'return_history_page.dart';

/// Profile page (Refactored - Zone-based Architecture)
///
/// Architecture:
/// - Zone 1: Page Shell (always renders) - Scaffold, AppBar, ScrollView
/// - Zone 2: Profile Data Zone (API-dependent) - ProfileHeader with internal state handling
/// - Zone 3: Actions & Links (API-independent) - Always visible
///
/// Rules:
/// - Authentication gates page access (redirects to login if tokens missing)
/// - Profile API state only affects ProfileHeader, not entire page
/// - Errors are localized, not page-killing
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Allow unauthenticated viewing - login is only required for protected actions
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // App-style header (centered title)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Text('Profile', style: AppTextStyles.headingMedium),
              ),
            ),
            // Scrollable content below header
            const Expanded(child: _ProfileContent()),
          ],
        ),
      ),
    );
  }
}

/// Profile content widget - Zone 1: Page Shell (Always Renders)
///
/// This widget always renders the page structure.
/// It does NOT block on profile state - that's handled by ProfileHeader.
class _ProfileContent extends ConsumerWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always render page structure - no blocking checks here
    return SingleChildScrollView(
      child: Column(
        children: [
          // Zone 2: Profile Data Zone (API-dependent)
          // ProfileHeader handles its own loading/error/null states internally
          const _ProfileHeaderWrapper(),

          // Zone 3: Actions & Links (API-independent)
          // Always visible, never blocked by profile state
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProfileActionsSection(
              onOrdersTap: () {
                final authState = ref.read(authProvider);
                if (!authState.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderHistoryPage(),
                  ),
                );
              },
              onPreBookedTap: () {
                final authState = ref.read(authProvider);
                if (!authState.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PresaleOrderHistoryPage(),
                  ),
                );
              },
              onHelpCenterTap: () {
                // Placeholder - will be implemented in later steps
              },
              onWishlistTap: () {
                final authState = ref.read(authProvider);
                if (!authState.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistPage()),
                );
              },
              onScanCouponTap: () {
                // Placeholder - will be implemented in later steps
              },
              onCoinsTap: () {
                final authState = ref.read(authProvider);
                if (!authState.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CoinsPage()),
                );
              },
              onReturnsTap: () {
                final authState = ref.read(authProvider);
                if (!authState.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReturnHistoryPage()),
                );
              },
            ),
          ),

          // Footer Links - always visible
          const ProfileFooterLinks(
            onFAQsTap: null,
            onAboutUsTap: null,
            onTermsTap: null,
            onPrivacyTap: null,
          ),

          // Logout Button - only visible if logged in
          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authProvider);
              if (authState.isLoggedIn) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

/// Profile header wrapper - Zone 2: Profile Data Zone
///
/// Passes profile state to ProfileHeader.
/// ProfileHeader handles loading/error/null states internally.
/// This wrapper never blocks - ProfileHeader always renders.
class _ProfileHeaderWrapper extends ConsumerWidget {
  const _ProfileHeaderWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch entire profile state (not just profile) to handle loading/error
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);

    // Always render ProfileHeader - it handles its own states
    return ProfileHeader(
      // Pass state to ProfileHeader for internal handling
      profileState: profileState,
      onEditPressed: () {
        // Check authentication before allowing edit
        if (!authState.isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfilePage()),
        );
      },
    );
  }
}
