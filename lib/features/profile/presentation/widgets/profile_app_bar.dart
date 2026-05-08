import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom app bar for Profile page
/// 
/// Features:
/// - Back arrow on left
/// - Title "Profile" in center
/// - More options (3 dots) on right
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({
    super.key,
    this.onBackPressed,
    this.onMoreOptionsPressed,
  });

  final VoidCallback? onBackPressed;
  final VoidCallback? onMoreOptionsPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Profile',
        style: AppTextStyles.headingMedium,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: onMoreOptionsPressed ?? () {
            // Placeholder for more options
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
