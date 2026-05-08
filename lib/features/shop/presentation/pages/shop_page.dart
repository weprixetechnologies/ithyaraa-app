import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/shop_controller.dart';
import '../providers/shop_provider.dart';
import '../widgets/header/shop_header.dart';
import '../widgets/offer_banner.dart';
import '../widgets/product_grid.dart';
import '../widgets/shop_bottom_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/sort_bottom_sheet.dart';
import '../../domain/entities/shop_filters.dart';
import '../../domain/entities/product.dart';
import '../../../product_detail/variable/presentation/pages/variable_product_detail_page.dart';
import '../../../product_detail/custom/presentation/pages/custom_product_pdp.dart';
import '../../../product_detail/makecombo/presentation/pages/makecombo_product_page.dart';
import '../../../product_detail/combo/presentation/pages/combo_product_pdp.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../search/presentation/pages/search_page.dart';

/// Shop page - reusable route page (not a tab)
class ShopPage extends ConsumerStatefulWidget {
  final String headerTitle;
  final ShopFilters? initialFilters;

  const ShopPage({super.key, required this.headerTitle, this.initialFilters});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8) {
      final shopState = ref.read(shopControllerProvider(widget.initialFilters));
      if (shopState.hasNextPage && !shopState.isLoadingMore) {
        final controller = ref.read(
          shopControllerProvider(widget.initialFilters).notifier,
        );
        controller.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to scope rebuilds - only rebuild parts that need to
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header - only rebuilds when totalItems or cartItemCount changes
            Consumer(
              builder: (context, ref, child) {
                final totalItems = ref.watch(
                  shopControllerProvider(
                    widget.initialFilters,
                  ).select((state) => state.totalItems),
                );
                final cartItemCount = ref.watch(
                  cartControllerProvider.select(
                    (state) => state.cartState?.itemCount ?? 0,
                  ),
                );
                final authState = ref.watch(authProvider);

                return ShopHeader(
                  title: widget.headerTitle,
                  subtitle: '$totalItems Results',
                  cartItemCount: cartItemCount > 0 ? cartItemCount : null,
                  onBackPressed: () => Navigator.of(context).pop(),
                  onSearchPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                  onWishlistPressed: () {
                    // Check if user is logged in
                    if (!authState.isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      return;
                    }
                    // Navigate to wishlist page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistPage(),
                      ),
                    );
                  },
                  onCartPressed: () {
                    // Check if user is logged in
                    if (!authState.isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      return;
                    }
                    // Navigate to cart page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                );
              },
            ),
            // Scrollable content - only rebuilds when products/loading/error change
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final shopState = ref.watch(
                    shopControllerProvider(widget.initialFilters),
                  );
                  final shopController = ref.read(
                    shopControllerProvider(widget.initialFilters).notifier,
                  );
                  return _buildContent(shopState, shopController);
                },
              ),
            ),
            // Bottom Bar - only rebuilds when filter count changes
            Consumer(
              builder: (context, ref, child) {
                final filters = ref.watch(
                  shopControllerProvider(
                    widget.initialFilters,
                  ).select((state) => state.filters),
                );
                final shopState = ref.read(
                  shopControllerProvider(widget.initialFilters),
                );
                final shopController = ref.read(
                  shopControllerProvider(widget.initialFilters).notifier,
                );
                return ShopBottomBar(
                  onSortTap: () =>
                      _showSortBottomSheet(context, shopState, shopController),
                  onFilterTap: () => _showFilterBottomSheet(
                    context,
                    shopState,
                    shopController,
                  ),
                  activeFilterCount: _getActiveFilterCount(filters),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ShopState state, ShopController controller) {
    if (state.isLoading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading products',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Offer Banner inside scroll view
          const SliverToBoxAdapter(
            child: RepaintBoundary(child: OfferBanner()),
          ),
          // Product Grid
          ProductGrid(
            products: state.products,
            isLoading: state.isLoadingMore,
            hasNextPage: state.hasNextPage,
            onLoadMore: () => controller.loadMore(),
            onProductTap: (product) {
              _navigateToProductDetail(context, product);
            },
            onWishlistTap: (product) {
              final authState = ref.read(authProvider);
              if (!authState.isLoggedIn) {
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
            },
            scrollController: null, // Not needed when using CustomScrollView
          ),
        ],
      ),
    );
  }

  int _getActiveFilterCount(ShopFilters? filters) {
    if (filters == null) return 0;
    int count = 0;
    if (filters.priceBands != null && filters.priceBands!.isNotEmpty) count++;
    if (filters.maxPrice != null) count++;
    if (filters.stock != null && filters.stock!.isNotEmpty) count++;
    return count;
  }

  void _navigateToProductDetail(BuildContext context, ProductEntity product) {
    // Normalize type — some APIs return 'custom', others 'customproduct'
    String productType = product.type ?? 'variable';
    if (productType == 'custom') productType = 'customproduct';
    final productIDString = product.productID;

    switch (productType) {
      case 'customproduct':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomProductPDP(product: product),
          ),
        );
        break;
      case 'makecombo':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MakeComboProductPage(productName: product.productName),
          ),
        );
        break;
      case 'combo':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComboProductPDP(productID: productIDString),
          ),
        );
        break;
      default:
        // variable and all other unknown types
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VariableProductDetailPage(productID: productIDString),
          ),
        );
    }
  }

  void _showSortBottomSheet(
    BuildContext context,
    ShopState state,
    ShopController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SortBottomSheet(
          scrollController: scrollController,
          currentSortBy: state.filters?.sortBy,
          currentSortOrder: state.filters?.sortOrder,
          onApplySort: (sortBy, sortOrder) {
            final updatedFilters = (state.filters ?? const ShopFilters())
                .copyWith(sortBy: sortBy, sortOrder: sortOrder);
            controller.updateFilters(updatedFilters);
          },
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    ShopState state,
    ShopController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => FilterBottomSheet(
          scrollController: scrollController,
          currentFilters: state.filters ?? const ShopFilters(),
          onApplyFilters: (filters) {
            controller.updateFilters(filters);
          },
        ),
      ),
    );
  }
}
