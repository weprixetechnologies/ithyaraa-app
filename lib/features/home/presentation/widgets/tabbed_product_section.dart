import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/models/section_models.dart';
import '../../../shop/presentation/widgets/product_card/product_card.dart';
import '../../../shop/presentation/widgets/product_card/product_card_skeleton.dart';
import '../../../shop/data/models/shop_response_model.dart';
import '../../../shop/data/datasources/shop_remote_datasource.dart';
import '../../../shop/domain/entities/shop_filters.dart';
import '../../../shop/domain/entities/product.dart';
import '../../../../core/theme/app_text_styles.dart';

class TabbedProductSection extends StatefulWidget {
  final List<HomeCategory> categories;

  const TabbedProductSection({super.key, required this.categories});

  @override
  State<TabbedProductSection> createState() => _TabbedProductSectionState();
}

class _TabbedProductSectionState extends State<TabbedProductSection> {
  int? _selectedCategoryID;
  List<ProductEntity> _products = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _limit = 12;

  late final ShopRemoteDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    debugPrint('[TabbedProductSection] initState');
    _dataSource = ShopRemoteDataSourceImpl(
      dio: Dio(
        BaseOptions(
          baseUrl: 'https://backend.ithyaraa.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ),
    );

    // Use a delayed post-frame callback to avoid blocking the startup path
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _fetchProducts();
      });
    });
  }

  Future<void> _fetchProducts({bool isLoadMore = false}) async {
    debugPrint(
      '[TabbedProductSection] Fetching products (isLoadMore: $isLoadMore)',
    );
    if (_isLoading || _isMoreLoading) return;

    setState(() {
      if (isLoadMore) {
        _isMoreLoading = true;
      } else {
        _isLoading = true;
        _products = [];
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      final filters = ShopFilters(
        categoryIDs: _selectedCategoryID != null
            ? [_selectedCategoryID!]
            : null,
        stock: 'in',
      );

      final response = await _dataSource.getShopProducts(
        page: _currentPage,
        limit: _limit,
        filters: filters,
      );
      debugPrint(
        '[TabbedProductSection] Received ${response.products.length} products',
      );

      if (mounted) {
        setState(() {
          if (isLoadMore) {
            _products.addAll(response.products);
          } else {
            _products = response.products;
          }
          _hasMore = response.pagination.hasNextPage;
          _isMoreLoading = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[TabbedProductSection] Error fetching products: $e');
      if (mounted) {
        setState(() {
          _isMoreLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  void _onCategorySelected(int? categoryID) {
    debugPrint('[TabbedProductSection] Category selected: $categoryID');
    if (_selectedCategoryID == categoryID) return;
    setState(() {
      _selectedCategoryID = categoryID;
    });
    _fetchProducts();
  }

  void _loadMore() {
    if (_hasMore && !_isMoreLoading) {
      debugPrint('[TabbedProductSection] Loading more...');
      _currentPage++;
      _fetchProducts(isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[TabbedProductSection] building');

    // Chunk products into pairs for 2-column layout without GridView
    final List<List<ProductEntity>> productPairs = [];
    for (var i = 0; i < _products.length; i += 2) {
      final end = (i + 2 < _products.length) ? i + 2 : _products.length;
      productPairs.add(_products.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Shop by Category",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Explore our amazing collection",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),

        // Category Tabs - Horizontally Scrollable
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildCategoryTab(null, "All Products"),
              ...widget.categories.map(
                (cat) => _buildCategoryTab(
                  cat.categoryID,
                  cat.categoryName,
                  cat.imageUrl,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Products List (using Column instead of GridView for stability)
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: const [
                      Expanded(child: ProductCardSkeleton()),
                      SizedBox(width: 12),
                      Expanded(child: ProductCardSkeleton()),
                    ],
                  ),
                ),
              ),
            ),
          )
        else if (_products.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text("No products found"),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: productPairs.map((pair) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: ProductCard(product: pair[0])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: pair.length > 1
                            ? ProductCard(product: pair[1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        if (_isMoreLoading)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: const [
                Expanded(child: ProductCardSkeleton()),
                SizedBox(width: 12),
                Expanded(child: ProductCardSkeleton()),
              ],
            ),
          ),

        if (!_hasMore && _products.isNotEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "You've seen all the products!",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),

        // Manual Load More Button for better stability in nested scrolls
        if (_hasMore && !_isLoading && !_isMoreLoading && _products.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: OutlinedButton(
                onPressed: _loadMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("View More Products"),
              ),
            ),
          ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCategoryTab(int? categoryID, String name, [String? imageUrl]) {
    final isSelected = _selectedCategoryID == categoryID;
    return GestureDetector(
      onTap: () => _onCategorySelected(categoryID),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
