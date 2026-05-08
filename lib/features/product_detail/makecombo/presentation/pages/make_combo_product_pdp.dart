import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/navigation/auth_navigation_service.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../cart/presentation/pages/cart_page.dart';
import '../../../../cart/presentation/providers/cart_provider.dart';
import '../../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../variable/presentation/widgets/product_image_carousel.dart';
import '../../../variable/presentation/widgets/product_info_section_v2.dart';
import '../../../variable/presentation/widgets/price_section_v2.dart';
import '../../../combo/domain/entities/combo_product.dart';
import '../providers/make_combo_detail_provider.dart';
import '../state/make_combo_detail_state.dart';
import '../controllers/make_combo_detail_controller.dart';
import '../widgets/make_combo_product_selection_modal.dart';
import '../widgets/make_combo_selected_product_card.dart';
import '../../../../buy_now/presentation/widgets/buy_now_button.dart';
import '../../../../buy_now/presentation/state/buy_now_state.dart';

/// Make Combo Product Detail Page: API-driven, Riverpod, no dummy data.
/// Navigate with productID (make-combo product id).
class MakeComboProductPDP extends ConsumerStatefulWidget {
  final String productID;

  const MakeComboProductPDP({super.key, required this.productID});

  @override
  ConsumerState<MakeComboProductPDP> createState() =>
      _MakeComboProductPDPState();
}

class _MakeComboProductPDPState extends ConsumerState<MakeComboProductPDP> {
  int _currentImageIndex = 0;
  bool _hasOpenedModalOnce = false;

  @override
  void initState() {
    super.initState();
    AuthNavigationService.setCurrentPath('makecombo:${widget.productID}');
  }

  @override
  void dispose() {
    AuthNavigationService.setCurrentPath(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      makeComboDetailControllerProvider(widget.productID),
    );
    final controller = ref.read(
      makeComboDetailControllerProvider(widget.productID).notifier,
    );

    // Auto-open selection modal once when detail has loaded and no selection yet
    if (state.detail != null &&
        state.selectedProducts.isEmpty &&
        !_hasOpenedModalOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _hasOpenedModalOnce = true;
        _openSelectionModal(context, state, controller);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildContent(state, controller),
      bottomNavigationBar: state.detail != null
          ? _buildBottomBar(state, controller)
          : null,
    );
  }

  Future<void> _openSelectionModal(
    BuildContext context,
    MakeComboDetailState state,
    MakeComboDetailController controller,
  ) async {
    if (state.detail == null || state.detail!.products.isEmpty) return;
    final result = await MakeComboProductSelectionModal.show(
      context,
      eligibleProducts: state.detail!.products,
      currentSelection: state.selectedProducts,
      maxProducts: MakeComboDetailState.maxProducts,
    );
    if (result != null && mounted) {
      controller.applySelection(result);
    }
  }

  Widget _buildContent(
    MakeComboDetailState state,
    MakeComboDetailController controller,
  ) {
    if (state.isLoading && state.detail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.detail == null) {
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
              onPressed: () => controller.retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.detail == null) {
      return const Center(child: Text('Combo not found'));
    }

    final combo = state.detail!;
    // Combine featured and gallery images for carousel (same as variable PDP)
    final allImages = [...combo.featuredImages, ...combo.galleryImages];

    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: ProductImageCarousel(
            images: allImages.isNotEmpty ? allImages : combo.featuredImages,
            currentIndex: _currentImageIndex,
            rating: combo.rating,
            reviewCount: combo.reviewCount,
            isWishlisted: false,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
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
        SliverToBoxAdapter(
          child: ProductInfoSectionV2(
            brandName: combo.brand,
            productName: combo.productName,
            rating: combo.rating,
            reviewCount: combo.reviewCount,
          ),
        ),
        SliverToBoxAdapter(
          child: PriceSectionV2(
            salePrice: combo.salePrice,
            regularPrice: combo.regularPrice,
            discountPercentage: combo.discountPercentage,
          ),
        ),
        SliverToBoxAdapter(
          child: _buildSelectedProductsSection(state, controller),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
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
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.chevron_left),
              color: Colors.black,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
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
                      MaterialPageRoute(builder: (context) => const CartPage()),
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
    );
  }

  Widget _buildSelectedProductsSection(
    MakeComboDetailState state,
    MakeComboDetailController controller,
  ) {
    final hasSelection = state.selectedProducts.isNotEmpty;
    final count = state.selectedProducts.length;
    final label = hasSelection
        ? 'Add More Products ($count/${MakeComboDetailState.maxProducts})'
        : 'Select Products';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Selected Products',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...state.selectedProducts.map((product) {
          final selectedVariation = state.getSelectedVariation(
            product.productID,
          );
          final selectedAttributes = state.getSelectedAttributes(
            product.productID,
          );
          return MakeComboSelectedProductCard(
            product: product,
            selectedVariation: selectedVariation,
            selectedAttributes: selectedAttributes,
            onVariationChanged: (_, attributes) {
              controller.updateSelectedAttributes(
                product.productID,
                attributes,
              );
            },
            onRemove: () => controller.removeProduct(product.productID),
          );
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await _openSelectionModal(context, state, controller);
              },
              icon: const Icon(Icons.add_shopping_cart_outlined, size: 20),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    MakeComboDetailState state,
    MakeComboDetailController controller,
  ) {
    final hasSelection = state.selectedProducts.isNotEmpty;
    final detail = state.detail!;

    // Prepare selected items for Buy Now state
    final selectedItems = state.selectedProducts.map((p) {
      final vid = state.selectedVariations[p.productID];
      return {
        'productID': p.productID,
        'variationID': vid,
      };
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
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (hasSelection)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: state.quantity <= 1
                          ? null
                          : () => controller.updateQuantity(state.quantity - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${state.quantity}',
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          controller.updateQuantity(state.quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
              else
                const SizedBox(width: 48, height: 48),
              const SizedBox(width: 12),
              Expanded(
                child: _MakeComboAddToCartButton(
                  productID: widget.productID,
                  quantity: state.quantity,
                  selectedProducts: state.selectedProducts,
                  selectedVariations: state.selectedVariations,
                  canAddToCart: state.canAddToCart,
                  onSuccess: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Combo added to cart successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onError: (message) {
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
                  isEnabled: state.canAddToCart,
                  initialState: BuyNowState(
                    productType: 'make_combo',
                    productID: widget.productID,
                    productName: detail.productName,
                    productImage: detail.featuredImages.isNotEmpty ? detail.featuredImages.first.imgUrl : null,
                    salePrice: detail.salePrice ?? 0.0,
                    regularPrice: detail.regularPrice ?? 0.0,
                    quantity: state.quantity,
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
}

class _MakeComboAddToCartButton extends ConsumerWidget {
  final String productID;
  final int quantity;
  final List<ComboProductEntity> selectedProducts;
  final Map<String, String?> selectedVariations;
  final bool canAddToCart;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  const _MakeComboAddToCartButton({
    required this.productID,
    required this.quantity,
    required this.selectedProducts,
    required this.selectedVariations,
    required this.canAddToCart,
    required this.onSuccess,
    required this.onError,
  });

  List<Map<String, String>> _buildProductsArray() {
    final list = <Map<String, String>>[];
    for (final p in selectedProducts) {
      final vid = selectedVariations[p.productID];
      if (vid != null && vid.isNotEmpty) {
        list.add({'productID': p.productID, 'variationID': vid});
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const themeColor = Color.fromRGBO(255, 210, 50, 1.0);
    final isLoading = ref.watch(
      addComboToCartButtonProvider(productID).select((s) => s.isLoading),
    );
    final addController = ref.read(
      addComboToCartButtonProvider(productID).notifier,
    );

    return ElevatedButton(
      onPressed: canAddToCart && !isLoading
          ? () async {
              final products = _buildProductsArray();
              if (products.length != selectedProducts.length) {
                onError('Please select options for all products');
                return;
              }
              await addController.addComboToCart(
                quantity: quantity,
                products: products,
              );
              Future.delayed(const Duration(milliseconds: 100), () {
                final s = ref.read(addComboToCartButtonProvider(productID));
                if (s.isSuccess) {
                  onSuccess();
                } else if (s.error != null) {
                  onError(s.error!);
                }
              });
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canAddToCart ? themeColor : Colors.grey.shade300,
        foregroundColor: canAddToCart ? Colors.black : Colors.grey.shade600,
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
