import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'drawer_nav_item.dart';

/// Drawer Footer Section
/// 
/// PERFORMANCE OPTIMIZATION:
/// - Uses Consumer with select() to watch ONLY auth state
/// - This section rebuilds ONLY when auth state changes
/// - Other drawer sections remain stateless and do NOT rebuild
/// - Contains multiple small sections with title + 2 list items
class DrawerFooterSection extends ConsumerWidget {
  final List<DrawerFooterSectionModel> sections;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;

  const DrawerFooterSection({
    super.key,
    required this.sections,
    this.onLoginTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch ONLY isLoggedIn - minimal rebuild scope
    final isLoggedIn = ref.watch(
      authProvider.select((state) => state.isLoggedIn),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        const Divider(height: 32),
        // Footer sections
        ...sections.map((section) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                Text(
                  section.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                // Section items
                ...section.items.map((item) {
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      item.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    onTap: item.onTap,
                  );
                }),
              ],
            ),
          );
        }),
        // Login/Logout button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoggedIn ? onLogoutTap : onLoginTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn
                    ? Colors.red.shade50
                    : Colors.blue.shade50,
                foregroundColor: isLoggedIn ? Colors.red : Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isLoggedIn ? 'Logout' : 'Login',
                style: AppTextStyles.button.copyWith(
                  color: isLoggedIn ? Colors.red : Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
