import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/offer_controller.dart';
import '../providers/offer_provider.dart';
import '../state/offer_state.dart';
import '../../domain/entities/offer.dart';
import '../../../../features/shop/presentation/widgets/product_card/product_card.dart';
import '../../../../features/shop/domain/entities/product.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/navigation/presentation/providers/navigation_provider.dart';

class OfferListPage extends ConsumerStatefulWidget {
  const OfferListPage({super.key});

  @override
  ConsumerState<OfferListPage> createState() => _OfferListPageState();
}

class _OfferListPageState extends ConsumerState<OfferListPage>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final PageController _heroPageController;
  late final PageController _mobilePageController;

  Timer? _heroTimer;
  Timer? _mobileTimer;
  Timer? _scrollDebounce;

  bool _showFab = false;

  late final AnimationController _mobileProgressController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _heroPageController = PageController();
    _mobilePageController = PageController();

    _mobileProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Initial fetch handled by controller constructor, but we'll setup timers once data arrives.
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final showFab = _scrollController.offset > 300;
    if (_showFab != showFab) {
      setState(() => _showFab = showFab);
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8) {
      if (_scrollDebounce?.isActive ?? false) return;
      _scrollDebounce = Timer(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        final offerState = ref.read(offerControllerProvider(null));
        final controller = ref.read(offerControllerProvider(null).notifier);
        if (!offerState.isLoadingMore &&
            offerState.gridLoadedCount < offerState.gridProducts.length) {
          controller.loadMoreGridProducts();
        } else if (offerState.hasNextPage && !offerState.isLoadingMore) {
          controller.loadMore();
        }
      });
    }
  }

  void _startTimersIfNeeded(OfferState state) {
    final heroOffers = state.offers
        .where((o) => o.offerBanner != null && o.offerBanner!.isNotEmpty)
        .toList();
    if (heroOffers.isNotEmpty && _heroTimer == null) {
      _heroTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!_heroPageController.hasClients) return;
        final currentState = ref.read(offerControllerProvider(null));
        int nextIndex = currentState.activeBannerIndex + 1;
        if (nextIndex >= heroOffers.length) nextIndex = 0;
        _heroPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }

    final mobileOffers = state.offers
        .where(
          (o) => o.offerMobileBanner != null && o.offerMobileBanner!.isNotEmpty,
        )
        .toList();
    if (mobileOffers.isNotEmpty && _mobileTimer == null) {
      _mobileProgressController.forward(from: 0.0);
      _mobileTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!_mobilePageController.hasClients) return;
        final currentState = ref.read(offerControllerProvider(null));
        int nextIndex = currentState.activeMobileBannerIndex + 1;
        if (nextIndex >= mobileOffers.length) nextIndex = 0;
        _mobilePageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _mobileProgressController.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroPageController.dispose();
    _mobilePageController.dispose();
    _heroTimer?.cancel();
    _mobileTimer?.cancel();
    _scrollDebounce?.cancel();
    _mobileProgressController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _onBackPressed() {
    ref.read(navigationProvider.notifier).setIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    final offerState = ref.watch(offerControllerProvider(null));
    final controller = ref.read(offerControllerProvider(null).notifier);

    // Listen to state changes to manage timers
    ref.listen<OfferState>(offerControllerProvider(null), (previous, next) {
      if (!next.isLoading && next.offers.isNotEmpty) {
        _startTimersIfNeeded(next);
      } else if (next.offers.isEmpty || next.isLoading) {
        _heroTimer?.cancel();
        _heroTimer = null;
        _mobileTimer?.cancel();
        _mobileTimer = null;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          _heroTimer?.cancel();
          _heroTimer = null;
          _mobileTimer?.cancel();
          _mobileTimer = null;
          await controller.refresh();
        },
        child: offerState.isLoading && offerState.offers.isEmpty
            ? _buildShimmerLoading()
            : offerState.error != null && offerState.offers.isEmpty
            ? _buildErrorState(offerState.error!, controller)
            : offerState.offers.isEmpty
            ? _buildEmptyState()
            : _buildContent(offerState, controller),
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              mini: true,
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
    );
  }

  Widget _buildContent(OfferState state, OfferController controller) {
    final heroOffers = state.offers
        .where((o) => o.offerBanner != null && o.offerBanner!.isNotEmpty)
        .toList();
    final mobileOffers = state.offers
        .where(
          (o) => o.offerMobileBanner != null && o.offerMobileBanner!.isNotEmpty,
        )
        .toList();

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFFFFD232),
          elevation: 0,
          pinned: true,
          leading: IconButton(
            onPressed: _onBackPressed,
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          title: Text(
            'Offers',
            style: AppTextStyles.headingMedium.copyWith(color: Colors.black87),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: Implement search
              },
              icon: const Icon(Icons.search, color: Colors.black87),
            ),
            IconButton(
              onPressed: () {
                // TODO: Navigate to cart
              },
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFFE0E0E0),
              height: 1.0,
            ),
          ),
        ),
        if (heroOffers.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildSection1HeroSlider(heroOffers, state, controller),
          ),
        if (heroOffers.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildSection2SyncedProducts(heroOffers, state),
          ),
        if (mobileOffers.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildSection3MobileSlider(mobileOffers, state, controller),
          ),
        _buildSection4StickyTabs(state, controller),
        _buildSection4Grid(state),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ), // Section 5 padding
      ],
    );
  }

  Widget _buildSection1HeroSlider(
    List<OfferEntity> offers,
    OfferState state,
    OfferController controller,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.width / 3, // 3:1 ratio
          child: PageView.builder(
            controller: _heroPageController,
            onPageChanged: controller.updateActiveBannerIndex,
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: offer.offerBanner!,
                          fit: BoxFit.cover,
                          memCacheWidth: 1000,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey.shade200),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        // Offer Type Pill
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (offer.offerType == 'buy_x_get_y')
                                  const Text(
                                    '🔥',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                if (offer.offerType == 'buy_x_get_y')
                                  const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    offer.offerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            offers.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: state.activeBannerIndex == index ? 20 : 6,
              decoration: BoxDecoration(
                color: state.activeBannerIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection2SyncedProducts(
    List<OfferEntity> offers,
    OfferState state,
  ) {
    if (offers.isEmpty || state.activeBannerIndex >= offers.length)
      return const SizedBox.shrink();

    final activeOffer = offers[state.activeBannerIndex];
    final products = activeOffer.products;

    if (products.isEmpty) return const SizedBox.shrink();

    Color chipColor = Colors.grey;
    String chipLabel = "Offer";
    if (activeOffer.offerType == 'buy_x_get_y') {
      chipColor = Colors.orange;
      chipLabel =
          "Buy ${activeOffer.buyCount ?? 'X'} Get ${activeOffer.getCount ?? 'Y'}";
    } else if (activeOffer.offerType == 'discount') {
      chipColor = Colors.green;
      chipLabel = "Discount";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeOffer.offerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activeOffer.offerType == 'buy_x_get_y')
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Limited offer',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    color: chipColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 350, // Approximate height for ProductCard + text
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: ListView.separated(
              key: ValueKey<String>(
                activeOffer.offerID,
              ), // Important for AnimatedSwitcher
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.48,
                  child: ProductCard(
                    product: products[index],
                    onTap: () {
                      // Navigate to PDP
                    },
                  ),
                );
              },
            ),
          ),
        ),
        if (products.length >= 10)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to filtered product list
                },
                child: const Text('View More'),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection3MobileSlider(
    List<OfferEntity> offers,
    OfferState state,
    OfferController controller,
  ) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width, // 1:1 ratio
          child: PageView.builder(
            controller: _mobilePageController,
            onPageChanged: (idx) {
              controller.updateActiveMobileBannerIndex(idx);
              _mobileProgressController.forward(from: 0.0); // Reset timer bar
            },
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              Color chipColor = Colors.grey;
              if (offer.offerType == 'buy_x_get_y') chipColor = Colors.orange;
              if (offer.offerType == 'discount') chipColor = Colors.green;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: offer.offerMobileBanner!,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      // Gradient Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Text & Badge
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                offer.offerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: chipColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                offer.offerType.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress Bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _mobileProgressController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: state.activeMobileBannerIndex == index
                                  ? _mobileProgressController.value
                                  : 0,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.5),
                              ),
                              minHeight: 3,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection4StickyTabs(
    OfferState state,
    OfferController controller,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        child: Container(
          height: 150, // Match delegate extent
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'All Offers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Explore products across all offers',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48, // Increased from 36 to prevent ChoiceChip overflow
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildTabChip(
                      'All',
                      null,
                      state.selectedOfferFilterId,
                      controller,
                    ),
                    ...state.offers.map(
                      (o) => _buildTabChip(
                        o.offerName,
                        o.offerID,
                        state.selectedOfferFilterId,
                        controller,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabChip(
    String label,
    String? id,
    String? selectedId,
    OfferController controller,
  ) {
    final isSelected = id == selectedId;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) controller.setFilterTab(id);
        },
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSection4Grid(OfferState state) {
    List<ProductEntity> displayProducts = state.gridProducts;
    if (state.selectedOfferFilterId != null) {
      final selectedOffer = state.offers.firstWhere(
        (o) => o.offerID == state.selectedOfferFilterId,
        orElse: () => state.offers.first,
      );
      displayProducts = state.gridProducts
          .where(
            (p) =>
                selectedOffer.products.any((op) => op.productID == p.productID),
          )
          .toList();
    }

    final loadCount = state.gridLoadedCount < displayProducts.length
        ? state.gridLoadedCount
        : displayProducts.length;
    final itemsToShow = displayProducts.take(loadCount).toList();

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55, // Adjust based on ProductCard height
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= itemsToShow.length) {
              if (state.isLoadingMore) {
                return const Center(child: CircularProgressIndicator());
              } else if (itemsToShow.length == displayProducts.length) {
                return const Center(
                  child: Text(
                    "You've seen it all ✓",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            final product = itemsToShow[index];
            // Find which offer it belongs to
            final offer = state.offers.firstWhere(
              (o) => o.products.any((op) => op.productID == product.productID),
              orElse: () => state.offers.first,
            );

            return Stack(
              children: [
                ProductCard(product: product, onTap: () {}),
                Positioned(
                  top: 8,
                  right: -4, // Adjust for ribbon look
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(-2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      offer.offerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          childCount:
              itemsToShow.length +
              (state.isLoadingMore ||
                      itemsToShow.length == displayProducts.length
                  ? 1
                  : 0),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 24),
        Container(height: 20, width: 100, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: MediaQuery.of(context).size.width - 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, OfferController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading offers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No offers available right now',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 150.0;
  @override
  double get maxExtent => 150.0;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
