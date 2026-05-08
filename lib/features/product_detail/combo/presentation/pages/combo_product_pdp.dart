import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/navigation/auth_navigation_service.dart';
import '../providers/combo_detail_provider.dart';
import '../controllers/combo_detail_controller.dart';
import '../../domain/entities/combo_detail.dart';
import '../../../variable/presentation/widgets/product_image_carousel.dart';
import '../../../variable/domain/entities/product_image.dart';
import '../../../variable/presentation/widgets/product_info_section_v2.dart';
import '../../../variable/presentation/widgets/price_section_v2.dart';
import '../../../variable/presentation/widgets/reviews_section.dart';
import '../../../variable/presentation/widgets/secondary_actions_section.dart';
import '../../../variable/presentation/widgets/expandable_detail_section.dart';
import '../widgets/combo_product_selector.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../../cart/presentation/pages/cart_page.dart';
import '../../../../cart/presentation/providers/cart_provider.dart';
import '../../../../shop/domain/entities/product.dart';
import '../../../../shop/domain/entities/image.dart';
import '../../../../buy_now/presentation/widgets/buy_now_button.dart';
import '../../../../buy_now/presentation/state/buy_now_state.dart';

/// Combo Product PDP page matching Variable PDP structure
class ComboProductPDP extends ConsumerStatefulWidget {
  final String productID;

  const ComboProductPDP({super.key, required this.productID});

  @override
  ConsumerState<ComboProductPDP> createState() => _ComboProductPDPState();
}

class _ComboProductPDPState extends ConsumerState<ComboProductPDP> {
  ProductImageEntity? _selectedImage;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    AuthNavigationService.setCurrentPath('combo:${widget.productID}');
    // Load wishlist when page opens (matching Variable PDP)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistProvider.notifier).loadWishlist();
    });
  }

  @override
  void dispose() {
    AuthNavigationService.setCurrentPath(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comboDetailControllerProvider(widget.productID));
    final controller = ref.read(
      comboDetailControllerProvider(widget.productID).notifier,
    );

    // Watch wishlist state to check if product is wishlisted
    final isWishlisted = state.comboDetail != null
        ? ref.watch(
            wishlistProvider.select(
              (wishlistState) =>
                  wishlistState.containsProduct(state.comboDetail!.productID),
            ),
          )
        : false;

    // Set initial selected image
    if (_selectedImage == null && state.comboDetail != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && state.comboDetail!.featuredImages.isNotEmpty) {
          setState(() {
            _selectedImage = state.comboDetail!.featuredImages.first;
            _currentImageIndex = 0;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildContent(state, controller, isWishlisted),
      bottomNavigationBar: state.comboDetail != null
          ? _buildBottomBar(state, controller)
          : null,
    );
  }

  Widget _buildContent(
    ComboDetailState state,
    ComboDetailController controller,
    bool isWishlisted,
  ) {
    if (state.isLoading && state.comboDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.comboDetail == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Error loading combo', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadComboDetail(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.comboDetail == null) {
      return const Center(child: Text('Combo not found'));
    }

    final combo = state.comboDetail!;
    // Combine featured and gallery images for carousel (same as variable PDP)
    final allImages = [...combo.featuredImages, ...combo.galleryImages];

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
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
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
                // Back button
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
            images: allImages.isNotEmpty ? allImages : combo.featuredImages,
            currentIndex: _currentImageIndex,
            rating: combo.rating,
            reviewCount: combo.reviewCount,
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
              final productEntity = _convertToProductEntity(combo);
              ref
                  .read(wishlistProvider.notifier)
                  .toggleWishlist(
                    combo.productID,
                    productEntity: productEntity,
                  );
            },
          ),
        ),
        // Gallery Thumbnails
        if (combo.galleryImages.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final thumbnailHeight = 50 * (222 / 170);
                  final thumbnailWidth = 50.0;
                  final spacing = 8.0;
                  final totalWidth =
                      combo.galleryImages.length * thumbnailWidth +
                      (combo.galleryImages.length - 1) * spacing;
                  final shouldScroll = totalWidth > constraints.maxWidth;

                  final content = Row(
                    mainAxisAlignment: shouldScroll
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: combo.galleryImages.map((image) {
                      final index = combo.galleryImages.indexOf(image);
                      final imageIndexInAll =
                          combo.featuredImages.length + index;
                      final isSelected = _currentImageIndex == imageIndexInAll;
                      return GestureDetector(
                        onTap: () {
                          if (imageIndexInAll < allImages.length) {
                            setState(() {
                              _currentImageIndex = imageIndexInAll;
                              _selectedImage = allImages[imageIndexInAll];
                            });
                          }
                        },
                        child: Container(
                          width: thumbnailWidth,
                          height: thumbnailHeight,
                          margin: EdgeInsets.only(
                            right: index < combo.galleryImages.length - 1
                                ? spacing
                                : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(
                              image.imgUrl,
                              width: thumbnailWidth,
                              height: thumbnailHeight,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: thumbnailWidth,
                                  height: thumbnailHeight,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );

                  if (shouldScroll) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: content,
                    );
                  }
                  return content;
                },
              ),
            ),
          ),
        // Product Info (Brand + Name + Rating)
        SliverToBoxAdapter(
          child: ProductInfoSectionV2(
            brandName: combo.brand,
            productName: combo.productName,
            rating: combo.rating,
            reviewCount: combo.reviewCount,
          ),
        ),
        // Price Section
        SliverToBoxAdapter(
          child: PriceSectionV2(
            salePrice: combo.salePrice,
            regularPrice: combo.regularPrice,
            discountPercentage: combo.discountPercentage,
          ),
        ),
        // Combo Product Breakdown
        if (combo.products.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    'Combo Products',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...combo.products.map((product) {
                  // Get selected attributes for this product (source of truth)
                  final selectedAttributes = state.getSelectedAttributes(
                    product.productID,
                  );

                  // Get resolved variation (if any)
                  final selectedVariation = state.getSelectedVariation(
                    product.productID,
                  );

                  return ComboProductSelector(
                    product: product,
                    selectedVariation: selectedVariation,
                    selectedAttributes: selectedAttributes,
                    onVariationChanged: (variation, attributes) {
                      // Update attributes (controller will resolve variation)
                      controller.updateSelectedAttributes(
                        product.productID,
                        attributes,
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        // Secondary Actions (Wishlist + Size Guide)
        SliverToBoxAdapter(
          child: SecondaryActionsSection(
            onAddToWishlist: () {
              final authState = ref.read(authProvider);
              if (!authState.isLoggedIn) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                return;
              }
              ref.read(wishlistProvider.notifier).toggleWishlist(
                    combo.productID,
                    productEntity: _convertToProductEntity(combo),
                  );
            },
            onSizeGuide: () => _showSizeGuide(context),
            isWishlisted: isWishlisted,
          ),
        ),
        // Description / Details
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (combo.description != null && combo.description!.isNotEmpty)
                ExpandableDetailItem(title: 'Description', content: combo.description),
              const ExpandableDetailItem(
                title: 'SHIPPING & DELIVERY',
                content: 'Shipping and delivery information will be displayed here.',
              ),
              const ExpandableDetailItem(
                title: 'RETURNS & WARRANTY',
                content: 'Returns and warranty information will be displayed here.',
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
                rating: combo.rating ?? 0.0,
                reviewCount: combo.reviewCount ?? 0,
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

  Widget _buildBottomBar(
    ComboDetailState state,
    ComboDetailController controller,
  ) {
    final combo = state.comboDetail!;
    
    // Prepare selected items for Buy Now state
    final selectedItems = state.selectedVariations.entries.map((e) => {
      'productID': e.key,
      'variationID': e.value,
    }).toList();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity for combo is usually 1, but we can add a text indicator
          const Text(
            'Quantity: 1 Bundle',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ComboAddToCartButton(
                  comboID: widget.productID,
                  quantity: 1,
                  selectedVariations: state.selectedVariations,
                  comboDetail: state.comboDetail,
                  isEnabled: state.allVariationsSelected,
                  onSuccess: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Combo added to cart successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onValidationError: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BuyNowButton(
                  isEnabled: state.allVariationsSelected,
                  initialState: BuyNowState(
                    productType: 'combo',
                    productID: widget.productID,
                    productName: combo.productName,
                    productImage: combo.featuredImages.isNotEmpty ? combo.featuredImages.first.imgUrl : null,
                    salePrice: combo.salePrice ?? 0.0,
                    regularPrice: combo.regularPrice ?? 0.0,
                    quantity: 1,
                    selectedItems: selectedItems,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Convert ComboDetailEntity to ProductEntity for wishlist
  ProductEntity _convertToProductEntity(ComboDetailEntity combo) {
    // Ensure proper type casting for featuredImages
    final List<ImageEntity> imageEntities = combo.featuredImages
        .map<ImageEntity>(
          (ProductImageEntity img) =>
              ImageEntity(imgUrl: img.imgUrl, imgAlt: img.imgAlt ?? ''),
        )
        .toList();

    return ProductEntity(
      productID: combo.productID,
      productName: combo.productName,
      description: combo.description,
      brand: combo.brand,
      type: 'combo',
      regularPrice: combo.regularPrice,
      salePrice: combo.salePrice,
      discountPercentage: combo.discountPercentage,
      rating: combo.rating,
      reviewCount: combo.reviewCount,
      featuredImages: imageEntities,
      categories: const [],
      inStock: combo.inStock,
    );
  }
}

/// Custom Add to Cart button for combo products
/// Uses provider-based architecture matching Variable PDP pattern
///
/// Note: comboID is the mainProductID in the add-to-cart payload
class _ComboAddToCartButton extends ConsumerWidget {
  /// The combo product ID (used as mainProductID in add-to-cart payload)
  final String comboID;
  final int quantity;
  final Map<String, String?> selectedVariations;
  final ComboDetailEntity? comboDetail;
  final bool isEnabled;
  final VoidCallback onSuccess;
  final Function(String) onValidationError;

  const _ComboAddToCartButton({
    required this.comboID,
    required this.quantity,
    required this.selectedVariations,
    required this.comboDetail,
    required this.isEnabled,
    required this.onSuccess,
    required this.onValidationError,
  });

  /// Validate that all products have selected variations
  /// Returns error message if validation fails, null if passes
  /// Validation rules (matching backend expectations):
  /// 1. comboDetail must not be null
  /// 2. selectedVariations.length == comboDetail.products.length
  /// 3. Every variationID != null && variationID.isNotEmpty
  String? _validateSelection() {
    if (comboDetail == null) {
      return 'Combo details not loaded';
    }

    // Validation: selectedVariations.length == comboDetail.products.length
    if (selectedVariations.length != comboDetail!.products.length) {
      return 'Please select options for all products in this combo';
    }

    // Validation: every variationID != null && variationID.isNotEmpty
    final isValid = selectedVariations.values.every(
      (v) => v != null && v.isNotEmpty,
    );

    if (!isValid) {
      return 'Please select options for all products in this combo';
    }

    return null; // Validation passed
  }

  /// Build products array for add-to-cart payload
  List<Map<String, String>> _buildProductsArray() {
    final products = <Map<String, String>>[];
    for (final entry in selectedVariations.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        products.add({'productID': entry.key, 'variationID': entry.value!});
      }
    }
    return products;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch loading state from provider
    final isLoading = ref.watch(
      addComboToCartButtonProvider(comboID).select((state) => state.isLoading),
    );

    final controller = ref.read(addComboToCartButtonProvider(comboID).notifier);

    // Use the exact theme color: rgb(255, 210, 50)
    const themeColor = Color.fromRGBO(255, 210, 50, 1.0);

    return ElevatedButton(
      onPressed: isEnabled && !isLoading
          ? () async {
              // UI-level validation (mandatory)
              final validationError = _validateSelection();
              if (validationError != null) {
                onValidationError(validationError);
                return;
              }

              // Build products array
              final products = _buildProductsArray();

              // Call controller (routes through use case → repository → data source)
              await controller.addComboToCart(
                quantity: quantity,
                products: products,
              );

              // Check success state after a brief delay
              Future.delayed(const Duration(milliseconds: 100), () {
                final state = ref.read(addComboToCartButtonProvider(comboID));
                if (state.isSuccess) {
                  onSuccess();
                } else if (state.error != null) {
                  onValidationError(state.error!);
                }
              });
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? themeColor : Colors.grey.shade300,
        foregroundColor: isEnabled ? Colors.black : Colors.grey.shade600,
        disabledBackgroundColor: Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : const Text(
              'Add to Cart',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }
}
