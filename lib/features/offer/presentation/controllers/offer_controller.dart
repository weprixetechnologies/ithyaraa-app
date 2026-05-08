import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/offer_filters.dart';
import '../../domain/usecases/get_all_offers_usecase.dart';
import '../state/offer_state.dart';
import '../../domain/entities/offer.dart';
import '../../../shop/domain/entities/product.dart';

/// Helper to extract, deduplicate, and sort grid products (top-level for isolate)
List<ProductEntity> _extractGridProductsWorker(List<OfferEntity> offers) {
  final Map<String, ProductEntity> deduplicatedMap = {};
  for (var offer in offers) {
    for (var p in offer.products) {
      if (!deduplicatedMap.containsKey(p.productID)) {
        deduplicatedMap[p.productID] = p;
      }
    }
  }
  final gridProducts = deduplicatedMap.values.toList();
  // Sort by createdAt descending, assuming createdAt exists or using a fallback
  gridProducts.sort((a, b) {
    final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return dateB.compareTo(dateA); 
  });
  return gridProducts;
}

/// Offer controller managing offer list page state
class OfferController extends StateNotifier<OfferState> {
  final GetAllOffersUseCase getAllOffersUseCase;
  final OfferFilters? initialFilters;

  OfferController(this.getAllOffersUseCase, {this.initialFilters})
      : super(OfferState(filters: initialFilters)) {
    loadOffers();
  }



  /// Load initial offers
  Future<void> loadOffers() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: 1,
      offers: [],
      gridProducts: [],
    );

    try {
      final response = await getAllOffersUseCase(
        page: 1,
        limit: 10, // Assuming 10 offers per page max
        filters: state.filters,
      );

      final gridProducts = await compute(_extractGridProductsWorker, response.offers);
      
      state = state.copyWith(
        offers: response.offers,
        isLoading: false,
        currentPage: 1,
        hasNextPage: response.offers.length >= 10,
        gridProducts: gridProducts,
        activeBannerIndex: 0,
        activeMobileBannerIndex: 0,
        gridLoadedCount: 10,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update active hero banner
  void updateActiveBannerIndex(int index) {
    if (state.activeBannerIndex != index) {
      state = state.copyWith(activeBannerIndex: index);
    }
  }

  /// Update active mobile banner
  void updateActiveMobileBannerIndex(int index) {
    if (state.activeMobileBannerIndex != index) {
      state = state.copyWith(activeMobileBannerIndex: index);
    }
  }

  /// Load more grid products for infinite scroll
  void loadMoreGridProducts() {
    if (state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    
    // Simulate slight delay for loading state
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      final currentCount = state.gridLoadedCount;
      final maxCount = state.gridProducts.length;
      
      if (currentCount < maxCount) {
        final newCount = (currentCount + 10 > maxCount) ? maxCount : currentCount + 10;
        state = state.copyWith(
          gridLoadedCount: newCount,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    });
  }

  /// Set the active sticky tab
  void setFilterTab(String? offerId) {
    if (offerId == null) {
      state = state.clearSelectedOfferFilterId();
    } else {
      state = state.copyWith(selectedOfferFilterId: offerId);
    }
  }

  /// Update filters and reload offers (if using old filter logic for entire list)
  Future<void> updateFilters(OfferFilters newFilters) async {
    state = state.copyWith(filters: newFilters);
    await loadOffers();
  }

  /// Load next page of offers
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await getAllOffersUseCase(
        page: nextPage,
        limit: 10,
        filters: state.filters,
      );

      final combinedOffers = [...state.offers, ...response.offers];
      final gridProducts = await compute(_extractGridProductsWorker, combinedOffers);

      state = state.copyWith(
        offers: combinedOffers,
        isLoadingMore: false,
        currentPage: nextPage,
        hasNextPage: response.offers.length >= 10,
        gridProducts: gridProducts,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Refresh offers
  Future<void> refresh() async {
    await loadOffers();
  }
}
