import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithyaraaapp/core/theme/app_text_styles.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/providers/product_detail_provider.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/controllers/product_detail_controller.dart';
import 'package:ithyaraaapp/features/product_detail/variable/domain/entities/product_image.dart';
import 'package:ithyaraaapp/features/product_detail/variable/domain/entities/variation.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/product_image_carousel.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/product_info_section_v2.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/price_section_v2.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/variation_selector_v2.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/product_offer_banner.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/action_buttons_section.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/secondary_actions_section.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/expandable_detail_section.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/reviews_section.dart';
import 'package:ithyaraaapp/features/cart/presentation/pages/cart_page.dart';
import 'package:ithyaraaapp/features/auth/presentation/pages/login_page.dart';
import 'package:ithyaraaapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:ithyaraaapp/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:ithyaraaapp/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:ithyaraaapp/features/shop/domain/entities/product.dart';
import 'package:ithyaraaapp/features/shop/domain/entities/image.dart';
import 'package:ithyaraaapp/features/product_detail/variable/domain/entities/product_detail.dart';

/// Variable product detail page
/// Currently, only variable products use full PDP logic. Other product types are implemented as placeholders and will be expanded later.
class VariableProductDetailPage extends ConsumerStatefulWidget {
  final String productID;

  const VariableProductDetailPage({super.key, required this.productID});

  @override
  ConsumerState<VariableProductDetailPage> createState() =>
      _VariableProductDetailPageState();
}

class _VariableProductDetailPageState
    extends ConsumerState<VariableProductDetailPage> {
  ProductImageEntity? _selectedImage;
  int _currentImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Load wishlist when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistProvider.notifier).loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailControllerProvider(widget.productID));
    final controller = ref.read(
      productDetailControllerProvider(widget.productID).notifier,
    );

    // Watch wishlist state to check if product is wishlisted
    final isWishlisted = state.productDetail != null
        ? ref.watch(
            wishlistProvider.select(
              (wishlistState) =>
                  wishlistState.containsProduct(state.productDetail!.productID),
            ),
          )
        : false;

    // Set initial selected image
    if (_selectedImage == null && state.productDetail != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && state.productDetail!.featuredImages.isNotEmpty) {
          setState(() {
            _selectedImage = state.productDetail!.featuredImages.first;
            _currentImageIndex = 0;
          });
        }
      });
    }

    final displayPrice = state.displayPrice;
    final displayRegularPrice = state.displayRegularPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildContent(state, controller, isWishlisted),
      bottomNavigationBar: state.productDetail != null
          ? ActionButtonsSection(
              productID: widget.productID,
              quantity: _quantity,
              onQuantityChanged: (newQuantity) {
                setState(() {
                  _quantity = newQuantity;
                });
              },
              variationID: state.selectedVariation?.variationID,
              variationName: _buildVariationName(state.selectedVariation),
              isEnabled: state.isInStock,
              hasVariations: state.productDetail!.variations.isNotEmpty,
              productName: state.productDetail!.productName,
              productImage: _selectedImage?.imgUrl ?? (state.productDetail!.featuredImages.isNotEmpty 
                  ? state.productDetail!.featuredImages.first.imgUrl 
                  : null),
              salePrice: displayPrice ?? 0.0,
              regularPrice: displayRegularPrice ?? 0.0,
              onValidationError: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              onAddToCartSuccess: () {
                // Show success message or navigate to cart
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item added to cart successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildContent(
    ProductDetailState state,
    ProductDetailController controller,
    bool isWishlisted,
  ) {
    if (state.isLoading && state.productDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.productDetail == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Error loading product', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadProductDetail(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.productDetail == null) {
      return const Center(child: Text('Product not found'));
    }

    final product = state.productDetail!;
    final displayPrice = state.displayPrice;
    final displayRegularPrice = state.displayRegularPrice;
    final discountPercentage = state.productDetail!.discountPercentage;

    // Combine featured and gallery images for carousel
    final allImages = [...product.featuredImages, ...product.galleryImages];

    return CustomScrollView(
      slivers: [
        // Custom minimal header (pinned)
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          floating: false,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button - same size as other icons
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.chevron_left),
                  color: Colors.black,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                // Right side icons: SHARE, WISHLIST, CART
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                      icon: const Icon(Icons.share_outlined),
                      color: Colors.black,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        final authState = ref.read(authProvider);
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
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.black,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        final authState = ref.read(authProvider);
                        if (!authState.isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      color: Colors.black,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Image Carousel
        SliverToBoxAdapter(
          child: ProductImageCarousel(
            images: allImages.isNotEmpty ? allImages : product.featuredImages,
            currentIndex: _currentImageIndex,
            rating: product.rating,
            reviewCount: product.reviewCount,
            isWishlisted: isWishlisted,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
                if (index < allImages.length) {
                  _selectedImage = allImages[index];
                }
              });
            },
            onQuickActionTap: () {
              final authState = ref.read(authProvider);
              if (!authState.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                return;
              }
              // Toggle wishlist
              final productEntity = _convertToProductEntity(product);
              ref
                  .read(wishlistProvider.notifier)
                  .toggleWishlist(
                    product.productID,
                    productEntity: productEntity,
                  );
            },
          ),
        ),
        // Removed Gallery Thumbnails - replaced by dots in carousel
        // Product Info (Brand + Name + Rating)
        SliverToBoxAdapter(
          child: ProductInfoSectionV2(
            brandName: product.brand,
            productName: product.productName,
            rating: product.rating,
            reviewCount: product.reviewCount,
          ),
        ),
        SliverToBoxAdapter(
          child: PriceSectionV2(
            salePrice: displayPrice,
            regularPrice: displayRegularPrice,
            discountPercentage: discountPercentage,
            isFlashSale: product.isFlashSale,
            flashSaleEndTime: product.flashSaleEndTime,
          ),
        ),
        // Offer Banner
        if (product.offer != null)
          SliverToBoxAdapter(
            child: ProductOfferBanner(
              offer: product.offer!,
            ),
          ),
        // Variation Selector
        if (product.variations.isNotEmpty)
          SliverToBoxAdapter(
            child: VariationSelectorV2(
              variations: product.variations,
              selectedVariation: state.selectedVariation,
              selectedAttributes: state.selectedAttributes,
              onVariationChanged: (variation, attributes) {
                // Always update the selected attributes (for partial selections)
                controller.updateSelectedAttributes(attributes);

                if (variation != null) {
                  // Complete variation selected - update the variation
                  controller.selectVariation(variation);
                  // Update selected image if variation has image
                  if (variation.imageUrl != null) {
                    try {
                      final matchingImage = allImages.firstWhere(
                        (img) => img.imgUrl == variation.imageUrl,
                      );
                      final index = allImages.indexOf(matchingImage);
                      setState(() {
                        _selectedImage = matchingImage;
                        _currentImageIndex = index >= 0 ? index : 0;
                      });
                    } catch (e) {
                      // Image not found, keep current selection
                    }
                  }
                }
                // If variation is null but attributes exist, we keep the partial selection
                // The controller already updated selectedAttributes above
              },
            ),
          ),
        // Divider after Variation Section
        if (product.variations.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              height: 3,
              width: double.infinity,
              color: Colors.grey.shade100,
            ),
          ),
        // Secondary Actions (Add to Wishlist + Size Guide)
        SliverToBoxAdapter(
          child: SecondaryActionsSection(
            onAddToWishlist: () {
              final authState = ref.read(authProvider);
              if (!authState.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                return;
              }
              // Toggle wishlist
              final productEntity = _convertToProductEntity(product);
              ref
                  .read(wishlistProvider.notifier)
                  .toggleWishlist(
                    product.productID,
                    productEntity: productEntity,
                  );
            },
            onSizeGuide: () {
              _showSizeGuide(context);
            },
            isWishlisted: isWishlisted,
          ),
        ),
        // Expandable Detail Sections
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Description
              if (product.description != null &&
                  product.description!.isNotEmpty)
                ExpandableDetailItem(
                  title: 'Description',
                  content: product.description,
                ),
              // Product Details
              if (product.tab1 != null && product.tab1!.isNotEmpty)
                ExpandableDetailItem(
                  title: 'PRODUCT DETAILS',
                  content: product.tab1,
                ),
              // Additional Information
              if (product.tab2 != null && product.tab2!.isNotEmpty)
                ExpandableDetailItem(
                  title: 'ADDITIONAL INFORMATION',
                  content: product.tab2,
                ),
              // Shipping & Delivery
              ExpandableDetailItem(
                title: 'SHIPPING & DELIVERY',
                content:
                    'Shipping and delivery information will be displayed here.',
              ),
              // Returns & Warranty
              ExpandableDetailItem(
                title: 'RETURNS & WARRANTY',
                content:
                    'Returns and warranty information will be displayed here.',
              ),
            ],
          ),
        ),
        // Reviews Section
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                color: Colors.grey.shade100,
              ),
              ReviewsSection(
                rating: product.rating ?? 0.0,
                reviewCount: product.reviewCount ?? 0,
              ),
            ],
          ),
        ),
        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  void _showSizeGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Size Guide',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find your perfect fit with our detailed size guide.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    // Placeholder for size guide table
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      children: const [
                        TableRow(
                          decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Chest (in)', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Waist (in)', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(8.0), child: Text('S')),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('36-38')),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('30-32')),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(8.0), child: Text('M')),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('39-41')),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('33-35')),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(8.0), child: Text('L')),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('42-44')),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('36-38')),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(8.0), child: Text('XL')),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('45-47')),
                            Padding(padding: EdgeInsets.all(8.0), child: Text('39-41')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'How to Measure?',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Chest: Measure around the fullest part of your chest, keeping the tape horizontal.\n'
                      '2. Waist: Measure around the narrowest part (typically where your body bends side to side), keeping the tape horizontal.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build variation name from selected variation attributes
  String? _buildVariationName(VariationEntity? variation) {
    if (variation == null) return null;
    if (variation.attributes.isEmpty) return null;

    // Build variation name from attributes (e.g., "Red / Large")
    return variation.attributes
        .map((attr) => '${attr.attributeName}: ${attr.attributeValue}')
        .join(' / ');
  }

  /// Convert ProductDetailEntity to ProductEntity for wishlist
  ProductEntity _convertToProductEntity(ProductDetailEntity productDetail) {
    return ProductEntity(
      productID: productDetail.productID,
      productName: productDetail.productName,
      description: productDetail.description,
      brand: productDetail.brand,
      type: 'variable',
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
      categories: const [], // ProductDetailEntity doesn't have categories
      inStock: productDetail.inStock,
      createdAt: null, // ProductDetail doesn't have createdAt but we should pass null
      isFlashSale: productDetail.isFlashSale,
      flashSaleEndTime: productDetail.flashSaleEndTime,
      flashSalePrice: productDetail.salePrice, // Use salePrice as fallback for flashSalePrice
    );
  }
}
