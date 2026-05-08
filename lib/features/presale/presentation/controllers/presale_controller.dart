import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/presale_repository.dart';
import '../../domain/entities/presale_product.dart';
import '../providers/presale_providers.dart';

class PresaleState {
  final List<PresaleProductEntity> products;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const PresaleState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  PresaleState copyWith({
    List<PresaleProductEntity>? products,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return PresaleState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PresaleController extends StateNotifier<PresaleState> {
  final PresaleRepository repository;

  PresaleController(this.repository) : super(const PresaleState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await repository.getPresaleProducts(page: state.currentPage);
      
      // Filter out expired products (matching website behavior)
      final now = DateTime.now();
      final activeProducts = response.products.where((p) {
        if (p.preSaleEndDate == null) return true;
        return p.preSaleEndDate!.isAfter(now);
      }).toList();

      state = state.copyWith(
        products: [...state.products, ...activeProducts],
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMore: response.pagination.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final presaleControllerProvider = StateNotifierProvider<PresaleController, PresaleState>((ref) {
  final repository = ref.watch(presaleRepositoryProvider);
  return PresaleController(repository);
});
