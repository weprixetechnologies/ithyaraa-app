import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'drawer_nav_item.dart';

/// Drawer Quick Actions Section
/// 
/// PERFORMANCE OPTIMIZATION:
/// - Stateless widget - no state management
/// - Displays 4 square items in a single row
/// - Equal spacing between items
/// - Does NOT rebuild when auth state changes
class DrawerQuickActionsSection extends StatelessWidget {
  final List<DrawerQuickAction> actions;

  const DrawerQuickActionsSection({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we only show 4 items
    final displayActions = actions.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: displayActions.map((action) {
          return Expanded(
            child: InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      action.icon,
                      size: 24,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
