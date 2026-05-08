import 'package:flutter/material.dart';

/// Hamburger menu button for Home Header
///
/// Stateless widget - no state management needed
/// Opens drawer via root Scaffold to appear over the bottom navigation bar.
class HeaderLeadingMenuButton extends StatelessWidget {
  const HeaderLeadingMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Open the drawer using the root Scaffold so it covers the bottom navigation bar
        context.findRootAncestorStateOfType<ScaffoldState>()?.openDrawer();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 2.5,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 16,
              height: 2.5,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 20,
              height: 2.5,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
