import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ithyaraaapp/features/shop/domain/entities/product.dart';
import 'package:ithyaraaapp/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:ithyaraaapp/features/cart/presentation/providers/cart_provider.dart';
import 'package:ithyaraaapp/features/cart/presentation/pages/cart_page.dart';
import 'package:ithyaraaapp/features/buy_now/presentation/widgets/buy_now_bottom_sheet.dart';
import 'package:ithyaraaapp/features/buy_now/presentation/state/buy_now_state.dart';
import 'package:ithyaraaapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:ithyaraaapp/features/auth/presentation/pages/login_page.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/product_info_section_v2.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/price_section_v2.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/product_image_carousel.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/secondary_actions_section.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/expandable_detail_section.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/quantity_selector.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/widgets/reviews_section.dart';
import 'package:ithyaraaapp/core/theme/app_text_styles.dart';
import 'package:ithyaraaapp/features/shop/domain/entities/image.dart';

import '../providers/custom_product_provider.dart';
import '../controllers/custom_product_controller.dart';
import '../../domain/entities/custom_product_detail.dart';
import '../widgets/custom_inputs_form.dart';
import '../widgets/dress_type_selector.dart';
import '../widgets/image_upload_zone.dart';
import '../widgets/confirm_customisation_sheet.dart';

class CustomProductPDP extends ConsumerStatefulWidget {
  final ProductEntity product;

  const CustomProductPDP({super.key, required this.product});

  @override
  ConsumerState<CustomProductPDP> createState() => _CustomProductPDPState();
}

class _CustomProductPDPState extends ConsumerState<CustomProductPDP> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistProvider.notifier).loadWishlist();
    });
  }

  void _handleQuantityChanged(int newQuantity) {
    if (newQuantity < 1) return;
    setState(() {
      _quantity = newQuantity;
    });
  }

  bool _validateForm() {
    final state = ref.read(customProductControllerProvider(widget.product.productID));
    final productDetail = state.productDetail;
    if (productDetail == null) return false;

    bool isValid = true;
    if (productDetail.dressTypes.isNotEmpty && state.selectedDressType == null) {
      isValid = false;
    }
    for (final input in productDetail.customInputs) {
      if (input.required) {
        final value = state.customInputValues[input.id];
        if (value == null || (value is String && value.trim().isEmpty)) {
          isValid = false;
          break;
        }
      }
    }

    if (!isValid) {
      setState(() => _showValidationErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required customization fields')),
      );
    } else {
      setState(() => _showValidationErrors = false);
    }
    return isValid;
  }

  Map<String, dynamic> _buildFinalCustomInputs(CustomProductState state) {
    final inputs = Map<String, dynamic>.from(state.customInputValues);
    if (state.uploadedImageUrl != null && state.uploadedImageUrl!.isNotEmpty) {
      inputs['customerUploadedImage'] = state.uploadedImageUrl;
    }
    return inputs;
  }

  void _handleAddToCartClick() {
    if (!_validateForm()) return;
    final state = ref.read(customProductControllerProvider(widget.product.productID));
    final productDetail = state.productDetail!;
    final allImages = [...productDetail.featuredImages, ...productDetail.galleryImages];

    ConfirmCustomisationSheet.show(
      context,
      productName: productDetail.productName,
      productImage: allImages.isNotEmpty ? allImages.first.imgUrl : null,
      quantity: _quantity,
      selectedDressType: state.selectedDressType,
      customInputs: productDetail.customInputs,
      customInputValues: state.customInputValues,
      isBuyNow: false,
      onConfirm: _dispatchAddToCart,
    );
  }

  void _handleBuyNowClick() {
    if (!_validateForm()) return;
    final state = ref.read(customProductControllerProvider(widget.product.productID));
    final productDetail = state.productDetail!;
    final allImages = [...productDetail.featuredImages, ...productDetail.galleryImages];
    final finalInputs = _buildFinalCustomInputs(state);

    BuyNowBottomSheet.show(
      context,
      BuyNowState(
        productType: 'customproduct',
        productID: widget.product.productID,
        quantity: _quantity,
        customInputs: finalInputs,
        selectedDressType: state.selectedDressType != null
            ? {'label': state.selectedDressType!.label, 'price': state.selectedDressType!.price}
            : null,
        productName: productDetail.productName,
        productImage: allImages.isNotEmpty ? allImages.first.imgUrl : null,
        salePrice: state.displayPrice ?? 0,
        regularPrice: productDetail.regularPrice ?? 0,
      ),
    );
  }

  Future<void> _dispatchAddToCart() async {
    final state = ref.read(customProductControllerProvider(widget.product.productID));
    final finalInputs = _buildFinalCustomInputs(state);

    final controller = ref.read(addToCartButtonProvider(widget.product.productID).notifier);
    await controller.addToCart(
      quantity: _quantity,
      customInputs: finalInputs,
      selectedDressType: state.selectedDressType != null
          ? {'label': state.selectedDressType!.label, 'price': state.selectedDressType!.price}
          : null,
    );

    if (!mounted) return;
    final cartState = ref.read(addToCartButtonProvider(widget.product.productID));
    if (cartState.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart successfully!')),
      );
    } else if (cartState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cartState.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.watch directly — autoDispose.family provider resolves correctly at runtime
    final state = ref.watch(customProductControllerProvider(widget.product.productID));
    final isWishlisted = state.productDetail != null
        ? ref.watch(
            wishlistProvider.select(
              (s) => s.containsProduct(state.productDetail!.productID),
            ),
          )
        : false;
    final isAddingToCart = ref.watch(
      addToCartButtonProvider(widget.product.productID).select((s) => s.isLoading),
    );

    final productDetail = state.productDetail;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: productDetail != null ? _buildBottomBar(isAddingToCart) : null,
      body: _buildBody(state, productDetail, isWishlisted),
    );
  }

  Widget _buildBody(CustomProductState state, CustomProductDetailEntity? productDetail, bool isWishlisted) {
    if (state.isLoading && productDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && productDetail == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Error loading product'),
            const SizedBox(height: 8),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(customProductControllerProvider(widget.product.productID).notifier)
                  .loadProductDetail(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (productDetail == null) {
      return const Center(child: Text('Product not found'));
    }

    final allImages = [...productDetail.featuredImages, ...productDetail.galleryImages];

    return CustomScrollView(
      slivers: [
        // ── Pinned AppBar matching variable PDP ──
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
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                          return;
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
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

        // ── Image Carousel ──
        SliverToBoxAdapter(
          child: ProductImageCarousel(
            images: allImages.isNotEmpty ? allImages : productDetail.featuredImages,
            currentIndex: _currentImageIndex,
            rating: productDetail.rating,
            reviewCount: productDetail.reviewCount,
            isWishlisted: isWishlisted,
            onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
            onQuickActionTap: () {
              final authState = ref.read(authProvider);
              if (!authState.isLoggedIn) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                return;
              }
              ref.read(wishlistProvider.notifier).toggleWishlist(
                    productDetail.productID,
                    productEntity: _toProductEntity(productDetail),
                  );
            },
          ),
        ),

        // ── Gallery thumbnails (same as variable PDP) ──
        if (productDetail.galleryImages.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: productDetail.galleryImages.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final image = entry.value;
                    final indexInAll = productDetail.featuredImages.length + idx;
                    final isSelected = _currentImageIndex == indexInAll;
                    return GestureDetector(
                      onTap: () => setState(() => _currentImageIndex = indexInAll),
                      child: Container(
                        width: 50,
                        height: 65,
                        margin: EdgeInsets.only(right: idx < productDetail.galleryImages.length - 1 ? 8 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(image.imgUrl, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

        // ── Product Info ──
        SliverToBoxAdapter(
          child: ProductInfoSectionV2(
            brandName: productDetail.brand,
            productName: productDetail.productName,
            rating: productDetail.rating,
            reviewCount: productDetail.reviewCount,
          ),
        ),

        // ── Price ──
        SliverToBoxAdapter(
          child: PriceSectionV2(
            salePrice: state.displayPrice,
            regularPrice: productDetail.regularPrice,
            discountPercentage: productDetail.discountPercentage,
          ),
        ),

        // ── Custom badge ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade50, const Color(0xFFFFFBEB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border.all(color: const Color(0xFFFFD232).withValues(alpha: 0.5), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD97706),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Made-to-Order · Crafted exclusively for you',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Dress Type Selector ──
        if (productDetail.dressTypes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(height: 1, color: Colors.grey.shade100, margin: const EdgeInsets.symmetric(vertical: 4)),
          ),
          SliverToBoxAdapter(
            child: DressTypeSelector(
              dressTypes: productDetail.dressTypes,
              selectedDressType: state.selectedDressType,
              showErrors: _showValidationErrors,
              onSelect: (dt) {
                ref.read(customProductControllerProvider(widget.product.productID).notifier).selectDressType(dt);
              },
            ),
          ),
        ],

        // ── Image Upload ──
        if (productDetail.allowCustomerImageUpload) ...[
          SliverToBoxAdapter(child: Container(height: 3, color: Colors.grey.shade100)),
          SliverToBoxAdapter(
            child: ImageUploadZone(
              allowUpload: true,
              uploadedImageUrl: state.uploadedImageUrl,
              isUploading: state.isUploading,
              onUploadStart: (s) =>
                  ref.read(customProductControllerProvider(widget.product.productID).notifier).setUploadingImage(s),
              onUploadComplete: (url) =>
                  ref.read(customProductControllerProvider(widget.product.productID).notifier).setUploadedImageUrl(url),
              onRemove: () =>
                  ref.read(customProductControllerProvider(widget.product.productID).notifier).removeUploadedImage(),
            ),
          ),
        ],

        // ── Custom Inputs Form ──
        if (productDetail.customInputs.isNotEmpty) ...[
          SliverToBoxAdapter(child: Container(height: 3, color: Colors.grey.shade100)),
          SliverToBoxAdapter(
            child: CustomInputsForm(
              inputs: productDetail.customInputs,
              values: state.customInputValues,
              showErrors: _showValidationErrors,
              onChanged: (id, val) {
                ref.read(customProductControllerProvider(widget.product.productID).notifier).updateCustomInput(id, val);
              },
            ),
          ),

        ],

        // ── Secondary Actions ──
        SliverToBoxAdapter(
          child: Container(height: 1, color: Colors.grey.shade100, margin: const EdgeInsets.symmetric(vertical: 4)),
        ),
        SliverToBoxAdapter(
          child: SecondaryActionsSection(
            onAddToWishlist: () {
              final authState = ref.read(authProvider);
              if (!authState.isLoggedIn) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                return;
              }
              ref.read(wishlistProvider.notifier).toggleWishlist(
                    productDetail.productID,
                    productEntity: _toProductEntity(productDetail),
                  );
            },
            onSizeGuide: () {
              _showSizeGuide(context);
            },
            isWishlisted: isWishlisted,
          ),
        ),

        // ── Expandable Accordions ──
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (productDetail.description != null && productDetail.description!.isNotEmpty)
                ExpandableDetailItem(title: 'Description', content: productDetail.description),
              if (productDetail.tab1 != null && productDetail.tab1!.isNotEmpty)
                ExpandableDetailItem(title: 'PRODUCT DETAILS', content: productDetail.tab1),
              if (productDetail.tab2 != null && productDetail.tab2!.isNotEmpty)
                ExpandableDetailItem(title: 'ADDITIONAL INFORMATION', content: productDetail.tab2),
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
                rating: productDetail.rating ?? 0.0,
                reviewCount: productDetail.reviewCount ?? 0,
              ),
            ],
          ),
        ),
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

  Widget _buildBottomBar(bool isAddingToCart) {
    const themeColor = Color(0xFFFFD232);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quantity :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuantitySelector(
                  quantity: _quantity,
                  onQuantityChanged: _handleQuantityChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isAddingToCart ? null : _handleAddToCartClick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isAddingToCart
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                            ),
                          )
                        : const Text(
                            'Add to Cart',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleBuyNowClick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ProductEntity _toProductEntity(CustomProductDetailEntity productDetail) {
    return ProductEntity(
      productID: productDetail.productID,
      productName: productDetail.productName,
      description: productDetail.description,
      brand: productDetail.brand,
      type: 'customproduct',
      regularPrice: productDetail.regularPrice,
      salePrice: productDetail.salePrice,
      discountPercentage: productDetail.discountPercentage,
      rating: productDetail.rating,
      reviewCount: productDetail.reviewCount,
      featuredImages: productDetail.featuredImages
          .map<ImageEntity>((img) => ImageEntity(imgUrl: img.imgUrl, imgAlt: img.imgAlt ?? ''))
          .toList(),
      categories: const [],
      inStock: productDetail.inStock,
    );
  }
}
