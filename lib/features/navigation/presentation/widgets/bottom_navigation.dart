import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../home/presentation/widgets/home_drawer.dart';
import '../../../category/presentation/pages/category_page.dart';
import '../../../offer/presentation/pages/offer_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import 'custom_bottom_nav_bar.dart';

class BottomNavigationWidget extends ConsumerStatefulWidget {
  const BottomNavigationWidget({super.key});

  @override
  ConsumerState<BottomNavigationWidget> createState() =>
      _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState
    extends ConsumerState<BottomNavigationWidget> {
  final List<Widget> _pages = const [
    HomePage(),
    CategoryPage(),
    OfferListPage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    final authState = ref.read(authProvider);
    
    // Home (index 0), Category (index 1), and Offer (index 2) are always accessible
    if (index == 0 || index == 1 || index == 2) {
      ref.read(navigationProvider.notifier).setIndex(index);
      return;
    }

    // Profile (index 3) requires authentication
    if (index == 3) {
      if (!authState.isLoggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }
      // User is logged in, navigate to profile
      ref.read(navigationProvider.notifier).setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider).currentIndex;

    return Scaffold(
      drawer: const HomeDrawer(),
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(onTap: _onTabTapped),
      ),
    );
  }
}
