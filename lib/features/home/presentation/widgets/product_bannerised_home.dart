import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/section_models.dart';
import '../../../shop/domain/entities/product.dart';
import '../../../shop/domain/entities/image.dart';
import '../../../shop/presentation/widgets/product_card/product_card.dart';
import '../../../product_detail/variable/presentation/pages/variable_product_detail_page.dart';
import '../../../product_detail/custom/presentation/pages/custom_product_pdp.dart';
import '../../../product_detail/makecombo/presentation/pages/makecombo_product_page.dart';
import '../../../product_detail/combo/presentation/pages/combo_product_pdp.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';

class ProductBannerisedHome extends ConsumerWidget {
  final ProductGroup group;
  final List<ProductItem> products;

  const ProductBannerisedHome({
    super.key,
    required this.group,
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (group.imageUrl != null && group.imageUrl!.isNotEmpty)
          Image.network(
            group.imageUrl!,
            fit: BoxFit.fitWidth,
            width: double.infinity,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey.shade200, height: 140),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270, // Increased height to prevent RenderFlex overflow (especially on wider screens)
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final p = products[index];
              final productEntity = _mapToEntity(p);
              
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2.6, // Smaller cards (about 2.6 visible)
                child: ProductCard(
                  key: ValueKey('home_product_card_${p.productID}'),
                  product: productEntity,
                  onTap: () => _navigateToProductDetail(context, productEntity),
                  onWishlistTap: () => _handleWishlistTap(context, ref),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _handleWishlistTap(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    if (!authState.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
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
  }

  ProductEntity _mapToEntity(ProductItem p) {
    // Parse prices - strip currency and common symbols
    double? regular;
    if (p.regularPrice != null) {
      regular = double.tryParse(p.regularPrice!.replaceAll(RegExp(r'[^0-9.]'), ''));
    }
    double? sale;
    if (p.salePrice != null) {
      sale = double.tryParse(p.salePrice!.replaceAll(RegExp(r'[^0-9.]'), ''));
    }

    // Normalize type: the section API may return 'custom' while the shop API
    // returns 'customproduct'. Canonicalize to 'customproduct' for consistency.
    String? type = p.type;
    if (type == 'custom') type = 'customproduct';

    return ProductEntity(
      productID: p.productID,
      productName: p.name,
      type: type ?? 'variable',
      regularPrice: regular,
      salePrice: sale,
      rating: p.rating,
      reviewCount: p.reviewCount,
      featuredImages: p.featuredImage
          .map((i) => ImageEntity(imgUrl: i.imgUrl, imgAlt: i.imgAlt ?? ''))
          .toList(),
      categories: const [],
    );
  }

  void _navigateToProductDetail(BuildContext context, ProductEntity product) {
    final productType = product.type ?? 'variable';
    final productID = product.productID;

    switch (productType) {
      case 'customproduct':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomProductPDP(product: product),
          ),
        );
        break;
      case 'combo':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComboProductPDP(productID: productID),
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
      default:
        // variable and everything else
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VariableProductDetailPage(productID: productID),
          ),
        );
    }
  }
}
