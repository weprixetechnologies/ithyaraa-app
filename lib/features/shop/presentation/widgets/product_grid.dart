import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import 'product_card/product_card.dart';

/// Product grid widget with pagination support
class ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;
  final bool isLoading;
  final bool hasNextPage;
  final VoidCallback? onLoadMore;
  final Function(ProductEntity)? onProductTap;
  final Function(ProductEntity)? onWishlistTap;
  final ScrollController? scrollController;

  const ProductGrid({
    super.key,
    required this.products,
    this.isLoading = false,
    this.hasNextPage = false,
    this.onLoadMore,
    this.onProductTap,
    this.onWishlistTap,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // If scrollController is null, we're inside CustomScrollView (use SliverGrid)
    if (scrollController == null) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8, // Reduced vertical gap between products
            // Optimized aspect ratio to better match ProductCard height
            // Reduces grid cell height to minimize vertical gaps
            childAspectRatio: 0.59,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Show loading indicator at the end if there's more to load
              if (index >= products.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final product = products[index];
              return RepaintBoundary(
                child: ProductCard(
                  key: ValueKey('product_${product.productID}'),
                  product: product,
                  onTap: () => onProductTap?.call(product),
                  onWishlistTap: () => onWishlistTap?.call(product),
                ),
              );
            },
            childCount: products.length + (hasNextPage && isLoading ? 1 : 0),
            addAutomaticKeepAlives: false, // Don't keep off-screen items alive
            addRepaintBoundaries:
                false, // We're adding RepaintBoundary manually
          ),
        ),
      );
    }

    // Otherwise, use GridView.builder for standalone usage
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8, // Reduced vertical gap between products
        // Optimized aspect ratio to better match ProductCard height
        // Reduces grid cell height to minimize vertical gaps
        childAspectRatio: 0.68,
      ),
      itemCount: products.length + (hasNextPage && isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end if there's more to load
        if (index >= products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final product = products[index];
        return RepaintBoundary(
          child: ProductCard(
            key: ValueKey('product_${product.productID}'),
            product: product,
            onTap: () => onProductTap?.call(product),
            onWishlistTap: () => onWishlistTap?.call(product),
          ),
        );
      },
    );
  }
}
