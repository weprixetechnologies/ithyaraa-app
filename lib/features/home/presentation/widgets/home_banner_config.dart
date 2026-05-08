import '../../../shop/domain/entities/shop_filters.dart';

/// Configuration for a single homepage banner.
class HomeBannerConfig {
  final String imagePath;
  final String headerTitle;
  final ShopFilters filters;

  const HomeBannerConfig({
    required this.imagePath,
    required this.headerTitle,
    required this.filters,
  });
}

/// Homepage banner configuration list.
///
/// Update the `imagePath` values to match the files you place in
/// `assets/images/homepage-banner/`.
const List<HomeBannerConfig> homeBannerConfigs = [
  HomeBannerConfig(
    imagePath: 'assets/images/homepage-banner/1x1---CFT-men-1755188060.webp',
    headerTitle: 'Slider 1',
    filters: ShopFilters(type: 'combo'),
  ),
  HomeBannerConfig(
    imagePath:
        'assets/images/homepage-banner/1x1-Shirts-Men-Sale-BANNER-1755188012.webp',
    headerTitle: 'Make Combo',
    filters: ShopFilters(type: 'make_combo'),
  ),
  HomeBannerConfig(
    imagePath:
        'assets/images/homepage-banner/1x1-July25-MadIniNdiaSale-Extended-72hours-IK-1755187851.gif',
    headerTitle: 'Custom Products',
    filters: ShopFilters(type: 'customproduct'),
  ),
];
