import 'package:flutter/material.dart';

import '../../../shop/presentation/pages/shop_page.dart';
import 'home_banner_config.dart';

/// Homepage banner slider with 1:1 image ratio and swipe gestures.
class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBannerTap(HomeBannerConfig config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopPage(
          headerTitle: config.headerTitle,
          initialFilters: config.filters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (homeBannerConfigs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1, // 1:1 image ratio
          child: PageView.builder(
            controller: _pageController,
            itemCount: homeBannerConfigs.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final config = homeBannerConfigs[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => _onBannerTap(config),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(config.imagePath, fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(homeBannerConfigs.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
