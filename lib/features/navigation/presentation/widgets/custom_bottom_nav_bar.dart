import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Custom bottom navigation bar with pill-shaped design and smooth animations
class CustomBottomNavBar extends ConsumerStatefulWidget {
  final Function(int)? onTap;

  const CustomBottomNavBar({super.key, this.onTap});

  @override
  ConsumerState<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends ConsumerState<CustomBottomNavBar> {
  // Local state for active index - isolated from parent
  late ValueNotifier<int> _activeIndex;

  @override
  void initState() {
    super.initState();
    // Initialize with current index from provider
    final currentIndex = ref.read(navigationProvider).currentIndex;
    _activeIndex = ValueNotifier<int>(currentIndex);
  }

  @override
  void dispose() {
    _activeIndex.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    // Update local state immediately for instant UI feedback
    _activeIndex.value = index;

    // Call parent callback if provided
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read provider state to sync if needed (without watching to avoid rebuilds)
    final navigationState = ref.read(navigationProvider);

    // Sync local state with provider state if different
    if (_activeIndex.value != navigationState.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _activeIndex.value != navigationState.currentIndex) {
          _activeIndex.value = navigationState.currentIndex;
        }
      });
    }

    // Watch auth state only for badge display
    final authState = ref.watch(authProvider);

    return RepaintBoundary(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ValueListenableBuilder<int>(
          valueListenable: _activeIndex,
          builder: (context, activeIndex, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: activeIndex == 0,
                  onTap: _handleTap,
                ),
                _NavItem(
                  index: 1,
                  icon: Icons.emoji_nature,
                  activeIcon: Icons.emoji_nature,
                  label: 'Category',
                  isActive: activeIndex == 1,
                  onTap: _handleTap,
                ),
                _NavItem(
                  index: 2,
                  icon: Icons.local_offer_outlined,
                  activeIcon: Icons.local_offer,
                  label: 'Offer',
                  isActive: activeIndex == 2,
                  onTap: _handleTap,
                ),
                _NavItem(
                  index: 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: activeIndex == 3,
                  onTap: _handleTap,
                  showBadge: !authState.isLoggedIn,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Individual navigation item with isolated animation state
class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Function(int) onTap;
  final bool showBadge;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? Colors.black : Colors.grey,
                  size: 24,
                ),
                if (showBadge && !isActive)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.black : Colors.grey,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
