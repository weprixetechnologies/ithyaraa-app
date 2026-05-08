import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'drawer_nav_item.dart';

/// Drawer Primary Navigation Section
/// 
/// PERFORMANCE OPTIMIZATION:
/// - Stateless widget - no state management
/// - Uses ListView.builder for efficient rendering
/// - Data-driven approach - items passed as config
/// - Does NOT rebuild when auth state changes
class DrawerPrimaryNavSection extends StatelessWidget {
  final List<DrawerNavItem> items;

  const DrawerPrimaryNavSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              item.icon,
              size: 20,
              color: Colors.black87,
            ),
          ),
          title: Text(
            item.label,
            style: AppTextStyles.bodyMedium,
          ),
          onTap: item.onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        );
      },
    );
  }
}
