import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/shop_filters.dart';
import '../../domain/usecases/get_shop_products_usecase.dart';

/// Shop page state
class ShopState {
  final List<ProductEntity> products;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalItems;
  final bool hasNextPage;
  final ShopFilters? filters;

  const ShopState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalItems = 0,
    this.hasNextPage = false,
    this.filters,
  });

  ShopState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalItems,
    bool? hasNextPage,
    ShopFilters? filters,
  }) {
    return ShopState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      filters: filters ?? this.filters,
    );
  }
}

/// Shop controller managing shop page state
class ShopController extends StateNotifier<ShopState> {
  final GetShopProductsUseCase getShopProductsUseCase;
  final ShopFilters? initialFilters;

  ShopController(this.getShopProductsUseCase, {this.initialFilters})
    : super(ShopState(filters: initialFilters)) {
    // Normalize filters so that type is never empty:
    // - If filters is null → default to type "variable"
    // - If filters.type is null/empty → set type to "variable"
    final normalizedFilters = _normalizeFilters(state.filters);
    state = state.copyWith(filters: normalizedFilters);
    loadProducts();
  }

  /// Ensure type is always non-empty by defaulting to "variable" when missing.
  ShopFilters _normalizeFilters(ShopFilters? filters) {
    if (filters == null) {
      return const ShopFilters(type: 'variable');
    }

    final type = filters.type;
    if (type == null || type.trim().isEmpty) {
      return filters.copyWith(type: 'variable');
    }

    return filters;
  }

  /// Load initial products
  Future<void> loadProducts() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: 1,
      products: [],
    );

    try {
      final response = await getShopProductsUseCase(
        page: 1,
        limit: 20,
        filters: state.filters,
      );

      state = state.copyWith(
        products: response.products,
        isLoading: false,
        currentPage: 1,
        totalItems: response.pagination.totalItems,
        hasNextPage: response.pagination.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update filters and reload products
  Future<void> updateFilters(ShopFilters newFilters) async {
    // Always normalize filters so type is never empty
    final normalizedFilters = _normalizeFilters(newFilters);
    state = state.copyWith(filters: normalizedFilters);
    await loadProducts();
  }

  /// Load next page of products
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await getShopProductsUseCase(
        page: nextPage,
        limit: 20,
        filters: state.filters,
      );

      state = state.copyWith(
        products: [...state.products, ...response.products],
        isLoadingMore: false,
        currentPage: nextPage,
        hasNextPage: response.pagination.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Refresh products
  Future<void> refresh() async {
    await loadProducts();
  }
}
