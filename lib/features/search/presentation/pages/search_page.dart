import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/search_provider.dart';
import '../controllers/search_controller.dart';
import '../../../../features/product_detail/variable/presentation/pages/variable_product_detail_page.dart';
import '../../../../features/product_detail/custom/presentation/pages/custom_product_page.dart';
import '../../../../features/product_detail/combo/presentation/pages/combo_product_pdp.dart';
import '../../../../features/product_detail/makecombo/presentation/pages/makecombo_product_page.dart';

/// Search page with search bar and product list
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchControllerProvider.notifier).searchProducts(query);
    });
  }

  void _navigateToProductDetail(String productID, String? productType) {
    final type = productType ?? 'variable';

    if (type == 'variable') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VariableProductDetailPage(productID: productID),
        ),
      );
    } else if (type == 'custom') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CustomProductPage(productName: '')),
      );
    } else if (type == 'makecombo') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MakeComboProductPage(productName: ''),
        ),
      );
    } else if (type == 'combo') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComboProductPDP(productID: productID),
        ),
      );
    } else {
      // Fallback to variable for unknown types
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VariableProductDetailPage(productID: productID),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final searchController = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black87,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // Search bar
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) {
                        searchController.searchProducts(query);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Search results
            Expanded(child: _buildSearchResults(searchState)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading search results',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (state.query != null) {
                  ref
                      .read(searchControllerProvider.notifier)
                      .searchProducts(state.query!);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.query == null || state.query!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Search for products',
              style: AppTextStyles.headingMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type a product name to search',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
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
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: AppTextStyles.headingMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        final product = state.products[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(product.name, style: AppTextStyles.bodyLarge),
          onTap: () {
            _navigateToProductDetail(product.productID, product.type);
          },
        );
      },
    );
  }
}
