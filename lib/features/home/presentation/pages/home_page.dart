import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_heading.dart';
import '../widgets/header/home_header.dart';
import '../widgets/home_page_sections_horizontal.dart';
import '../widgets/home_banner_slider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../shop/presentation/pages/shop_page.dart';
import '../../../shop/domain/entities/shop_filters.dart';
import '../../data/section_service.dart';
import '../widgets/product_bannerised_home.dart';
import '../widgets/imagized_section.dart';
import '../widgets/home_category_section.dart';
import '../widgets/home_presale_section.dart';
import '../widgets/home_reels_section.dart';
import '../../data/models/section_models.dart';
import '../widgets/featured_coupon_widget.dart';
import '../widgets/tabbed_product_section.dart';
import '../../../shop/presentation/widgets/product_card/product_card_skeleton.dart';

/// Home Page with optimized header and drawer
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _handleSearchPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  void _handleWishlistPressed(BuildContext context, bool isLoggedIn) {
    if (!isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WishlistPage()),
    );
  }

  void _handleCartPressed(BuildContext context, bool isLoggedIn) {
    if (!isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: false,
        body: Column(
          children: [
            Consumer(
              builder: (context, ref, child) {
                final isLoggedIn = ref.watch(
                  authProvider.select((state) => state.isLoggedIn),
                );

                return HomeHeader(
                  topPadding: statusBarHeight,
                  onSearchPressed: () => _handleSearchPressed(context),
                  onWishlistPressed: () =>
                      _handleWishlistPressed(context, isLoggedIn),
                  onCartPressed: () => _handleCartPressed(context, isLoggedIn),
                );
              },
            ),
            const Expanded(child: _HomeContent()),
          ],
        ),
      ),
    );
  }
}

/// Memoized home content widget
///
/// Separated to prevent rebuilds when auth state changes
/// Only the header (with callbacks) rebuilds on auth change
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late Future<List<SectionItem>> _sectionsFuture;
  late Future<List<HomeCategory>> _categoriesFuture;
  late Future<List<HomeCategory>> _customTabbedCategoriesFuture;
  late Future<List<ReelModel>> _reelsFuture;

  @override
  void initState() {
    super.initState();
    final service = SectionService();
    _sectionsFuture = service.fetchSectionItems();
    _categoriesFuture = service.fetchHomeCategories();
    _customTabbedCategoriesFuture = service.fetchCustomTabbedCategories();
    _reelsFuture = service.fetchReels();
  }

  Future<void> _handleRefresh() async {
    final service = SectionService();
    setState(() {
      _sectionsFuture = service.fetchSectionItems();
      _categoriesFuture = service.fetchHomeCategories();
      _customTabbedCategoriesFuture = service.fetchCustomTabbedCategories();
      _reelsFuture = service.fetchReels();
    });
    await Future.wait([
      _sectionsFuture,
      _categoriesFuture,
      _customTabbedCategoriesFuture,
      _reelsFuture,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SectionItem>>(
      future: _sectionsFuture,
      builder: (context, snapshot) {
        final allSections = snapshot.data ?? [];

        // Extract featured coupon if any
        final couponItem = allSections.cast<SectionItem?>().firstWhere(
          (s) => s?.type == 'featuredcoupon' && s?.coupon != null,
          orElse: () => null,
        );

        final dynamicSections = allSections
            .where((s) => s.type != 'featuredcoupon')
            .toList();

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Homepage sections horizontal scroll
                    const HomePageSectionsHorizontal(),
                    // Homepage banner slider (section after 1)
                    const SizedBox(height: 16),
                    const HomeBannerSlider(),
                    const SizedBox(height: 24),

                    // "HOT CATEGORIES" Section
                    FutureBuilder<List<HomeCategory>>(
                      future: _categoriesFuture,
                      builder: (context, catSnapshot) {
                        if (catSnapshot.hasData &&
                            catSnapshot.data!.isNotEmpty) {
                          return HomeCategorySection(
                            categories: catSnapshot.data!,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Rest of home content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          // Dynamic sections from /api/section-items
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 20.0,
                              ),
                              child: Column(
                                children: List.generate(
                                  2,
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: Row(
                                      children: const [
                                        Expanded(child: ProductCardSkeleton()),
                                        SizedBox(width: 12),
                                        Expanded(child: ProductCardSkeleton()),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: dynamicSections.map((s) {
                                if (s.type == 'productsection' &&
                                    s.group != null) {
                                  return ProductBannerisedHome(
                                    group: s.group!,
                                    products: s.products,
                                  );
                                } else if (s.type == 'imagesection' &&
                                    s.section != null) {
                                  return ImagizedSection(
                                    section: s.section!,
                                    images: s.images,
                                  );
                                }
                                return const SizedBox.shrink();
                              }).toList(),
                            ),

                          const SizedBox(height: 24),

                          // Reels Section
                          HomeReelsSection(reelsFuture: _reelsFuture),

                          const SizedBox(height: 20),

                          // Test buttons for type-based shop navigation
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ShopPage(
                                    headerTitle: 'Combo Products',
                                    initialFilters: ShopFilters(type: 'combo'),
                                  ),
                                ),
                              );
                            },
                            child: const Text('SHOP COMBO PRODUCTS'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ShopPage(
                                    headerTitle: 'Make Combo',
                                    initialFilters: ShopFilters(
                                      type: 'make_combo',
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Text('SHOP MAKE COMBO'),
                          ),
                          const SizedBox(height: 32),

                          // Home Presale Section
                          const HomePresaleSection(),
                          const SizedBox(height: 24),

                          // Tabbed Product Section at the bottom
                          FutureBuilder<List<HomeCategory>>(
                            future: _customTabbedCategoriesFuture,
                            builder: (context, catSnapshot) {
                              if (catSnapshot.hasData &&
                                  catSnapshot.data!.isNotEmpty) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  color: Colors.grey.shade50,
                                  child: TabbedProductSection(
                                    categories: catSnapshot.data!,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed floating coupon widget
            if (couponItem?.coupon != null)
              FeaturedCouponWidget(coupon: couponItem!.coupon!),
          ],
        );
      },
    );
  }
}
