import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../profile/presentation/state/profile_provider.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Drawer Profile Section
/// 
/// PERFORMANCE OPTIMIZATION:
/// - Uses Consumer with select() to watch ONLY auth state and profile
/// - This section rebuilds ONLY when:
///   - Auth state changes (login/logout)
///   - Profile data changes
/// - Other drawer sections remain stateless and do NOT rebuild
class DrawerProfileSection extends ConsumerWidget {
  const DrawerProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch ONLY isLoggedIn - minimal rebuild scope
    final isLoggedIn = ref.watch(
      authProvider.select((state) => state.isLoggedIn),
    );

    // Watch profile only if logged in
    final profileState = isLoggedIn
        ? ref.watch(profileProvider)
        : const ProfileState();

    final profile = profileState.profile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Circular Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profile?.imageUrl != null
                ? NetworkImage(profile!.imageUrl!)
                : null,
            child: profile?.imageUrl == null
                ? Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey.shade600,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name or "Guest user"
                Text(
                  isLoggedIn && profile != null
                      ? profile.name.isNotEmpty
                          ? profile.name
                          : 'User'
                      : 'Guest user',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Email or "Sign in to continue"
                Text(
                  isLoggedIn && profile != null
                      ? profile.email
                      : 'Sign in to continue',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
