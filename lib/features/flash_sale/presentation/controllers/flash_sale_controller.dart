import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithyaraaapp/features/flash_sale/data/repositories/flash_sale_repository_impl.dart';
import 'package:ithyaraaapp/features/shop/domain/entities/product.dart';

class FlashSaleState {
  final List<ProductEntity> products;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasNextPage;
  final DateTime? flashSaleEndTime;

  FlashSaleState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasNextPage = false,
    this.flashSaleEndTime,
  });

  FlashSaleState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasNextPage,
    DateTime? flashSaleEndTime,
  }) {
    return FlashSaleState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      flashSaleEndTime: flashSaleEndTime ?? this.flashSaleEndTime,
    );
  }
}

class FlashSaleController extends StateNotifier<FlashSaleState> {
  final FlashSaleRepository repository;

  FlashSaleController({required this.repository}) : super(FlashSaleState()) {
    loadProducts();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, products: [], currentPage: 1);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final result = await repository.getFlashSaleProducts(
        page: state.currentPage,
        limit: 12,
      );

      final List<ProductEntity> products = (result['products'] as List).cast<ProductEntity>();
      final pagination = result['pagination'] as Map<String, dynamic>;
      
      DateTime? endTime;
      if (products.isNotEmpty) {
        endTime = products.first.flashSaleEndTime;
      }

      state = state.copyWith(
        isLoading: false,
        products: products,
        hasNextPage: pagination['hasNextPage'],
        flashSaleEndTime: endTime,
        error: products.isEmpty ? 'No active flash sales right now' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await repository.getFlashSaleProducts(
        page: nextPage,
        limit: 12,
      );

      final List<ProductEntity> newProducts = (result['products'] as List).cast<ProductEntity>();
      final pagination = result['pagination'] as Map<String, dynamic>;

      state = state.copyWith(
        isLoadingMore: false,
        products: [...state.products, ...newProducts],
        currentPage: nextPage,
        hasNextPage: pagination['hasNextPage'],
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}
