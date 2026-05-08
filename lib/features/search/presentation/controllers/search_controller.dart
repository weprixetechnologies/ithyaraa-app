import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/search_response.dart';
import '../../domain/entities/search_product.dart';
import '../../domain/usecases/search_products_usecase.dart';

/// Search page state
class SearchState {
  final List<SearchProductEntity> products;
  final bool isLoading;
  final String? error;
  final String? query;

  const SearchState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.query,
  });

  SearchState copyWith({
    List<SearchProductEntity>? products,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}

/// Search controller managing search page state
class SearchController extends StateNotifier<SearchState> {
  final SearchProductsUseCase searchProductsUseCase;

  SearchController(this.searchProductsUseCase) : super(const SearchState());

  /// Search for products
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        products: [],
        isLoading: false,
        error: null,
        query: query,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: query);

    try {
      final response = await searchProductsUseCase(query.trim());
      state = state.copyWith(
        products: response.products,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    state = const SearchState();
  }
}
