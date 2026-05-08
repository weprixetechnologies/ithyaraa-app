import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/presale_detail_controller.dart';
import '../../domain/entities/presale_product_detail.dart';
import '../widgets/rolling_text.dart';
import '../widgets/presale_countdown_timer.dart';
import '../widgets/premium_prebook_button.dart';
import '../widgets/presale_buy_now_bottom_sheet.dart';
import '../../../product_detail/variable/presentation/widgets/product_image_carousel.dart';
import '../../../product_detail/variable/presentation/widgets/variation_selector_v2.dart';
import '../../../product_detail/variable/presentation/widgets/expandable_detail_section.dart';
import '../../../product_detail/variable/presentation/widgets/quantity_selector.dart';
import '../../../product_detail/variable/domain/entities/variation.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../product_detail/variable/domain/entities/product_detail.dart';
import '../../../shop/domain/entities/product.dart';
import '../../../shop/domain/entities/image.dart';

class PresalePDPPage extends ConsumerStatefulWidget {
  final String productID;

  const PresalePDPPage({super.key, required this.productID});

  @override
  ConsumerState<PresalePDPPage> createState() => _PresalePDPPageState();
}

class _PresalePDPPageState extends ConsumerState<PresalePDPPage> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(presaleDetailControllerProvider(widget.productID));
    final controller = ref.read(
      presaleDetailControllerProvider(widget.productID).notifier,
    );

    final isWishlisted = state.productDetail != null
        ? ref.watch(
            wishlistProvider.select(
              (w) => w.containsProduct(state.productDetail!.productID),
            ),
          )
        : false;

    if (state.isLoading && state.productDetail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }

    if (state.productDetail == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    final product = state.productDetail!;
    final allImages = [...product.featuredImages, ...product.galleryImages];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: QuantitySelector(
                quantity: state.quantity,
                onQuantityChanged: controller.updateQuantity,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PremiumPreBookButton(
                onPressed: () => _showBookingSheet(
                  context,
                  product,
                  state.selectedVariation,
                  state.quantity,
                ),
                text: product.isUpcoming ? 'COMING SOON' : 'PRE-BOOK NOW',
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(
              'PRE ORDER NOW',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Top Rolling Text
          const SliverToBoxAdapter(
            child: RollingText(
              text1: 'PRE ORDER NOW',
              text2: 'BOOKING HAVE STARTED',
            ),
          ),
          // Image Carousel
          SliverToBoxAdapter(
            child: ProductImageCarousel(
              images: allImages,
              currentIndex: _currentImageIndex,
              isWishlisted: isWishlisted,
              onPageChanged: (index) =>
                  setState(() => _currentImageIndex = index),
              onQuickActionTap: () => _toggleWishlist(product),
            ),
          ),
          // Info Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand?.toUpperCase() ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Rating Placeholder
                  const SizedBox(height: 12),
                  // Rating Placeholder
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (_) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.reviewCount ?? 0} Reviews',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${state.displayPrice?.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (state.displayRegularPrice != null)
                        Text(
                          '₹${state.displayRegularPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (product.discountPercentage != null)
                        Text(
                          '${product.discountPercentage!.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Full-width Timer Section
          if (product.isActive && product.preSaleEndDate != null)
            SliverToBoxAdapter(
              child: PresaleCountdownTimer(
                endTime: product.preSaleEndDate!,
                label: 'PRESALE ENDS IN:',
              ),
            ),
          // Description & Variations Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Variations
                  if (product.variations.isNotEmpty)
                    VariationSelectorV2(
                      variations: product.variations,
                      selectedVariation: state.selectedVariation,
                      selectedAttributes: state.selectedAttributes,
                      onVariationChanged: (v, attrs) {
                        controller.updateSelectedAttributes(attrs);
                        if (v != null) controller.selectVariation(v);
                      },
                    ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 24),
                  // Secondary Actions
                  Row(
                    children: [
                      _buildSecondaryAction(
                        icon: isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: isWishlisted ? 'IN WISHLIST' : 'WISHLIST',
                        color: isWishlisted ? Colors.red : Colors.black,
                        onTap: () => _toggleWishlist(product),
                      ),
                      const SizedBox(width: 24),
                      if (product.sizeChartUrl != null)
                        _buildSecondaryAction(
                          icon: Icons.straighten,
                          label: 'SIZE GUIDE',
                          onTap: () =>
                              _showSizeChart(context, product.sizeChartUrl!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Details
                  if (product.description != null)
                    ExpandableDetailItem(
                      title: 'DESCRIPTION',
                      content: product.description,
                    ),
                  if (product.tab1 != null)
                    ExpandableDetailItem(
                      title: 'PRODUCT DETAILS',
                      content: product.tab1,
                    ),
                  if (product.tab2 != null)
                    ExpandableDetailItem(
                      title: 'ADDITIONAL INFO',
                      content: product.tab2,
                    ),
                ],
              ),
            ),
          ),
          // Bottom Rolling Text
          const SliverToBoxAdapter(
            child: RollingText(
              text1: 'PRE ORDER NOW',
              text2: 'BOOKING HAVE STARTED',
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    Color color = Colors.black,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleWishlist(PresaleProductDetailEntity product) {
    ref
        .read(wishlistProvider.notifier)
        .toggleWishlist(
          product.productID,
          productEntity: _convertToProductEntity(product),
        );
  }

  void _showBookingSheet(
    BuildContext context,
    PresaleProductDetailEntity product,
    VariationEntity? variation,
    int quantity,
  ) {
    if (product.isUpcoming) return;
    if (product.variations.isNotEmpty && variation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select size/color first')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PresaleBuyNowBottomSheet(
        product: product,
        variation: variation,
        quantity: quantity,
      ),
    );
  }

  void _showSizeChart(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Size Guide'),
              leading: const CloseButton(),
            ),
            Image.network(url),
          ],
        ),
      ),
    );
  }

  ProductEntity _convertToProductEntity(
    PresaleProductDetailEntity productDetail,
  ) {
    return ProductEntity(
      productID: productDetail.productID,
      productName: productDetail.productName,
      description: productDetail.description,
      brand: productDetail.brand,
      type: 'presale',
      regularPrice: productDetail.regularPrice,
      salePrice: productDetail.salePrice,
      discountPercentage: productDetail.discountPercentage,
      rating: productDetail.rating,
      reviewCount: productDetail.reviewCount,
      featuredImages: productDetail.featuredImages
          .map(
            (img) => ImageEntity(imgUrl: img.imgUrl, imgAlt: img.imgAlt ?? ''),
          )
          .toList(),
      categories: const [],
      inStock: productDetail.inStock,
    );
  }
}
