import '../../domain/entities/offer.dart';
import '../../domain/entities/offer_filters.dart';
import '../../../shop/domain/entities/product.dart';

/// Offer state for managing offer list page
class OfferState {
  final List<OfferEntity> offers;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasNextPage;
  final OfferFilters? filters;

  // New UI state
  final int activeBannerIndex;
  final int activeMobileBannerIndex;
  final List<ProductEntity> gridProducts;
  final int gridLoadedCount;
  final String? selectedOfferFilterId;

  const OfferState({
    this.offers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasNextPage = false,
    this.filters,
    this.activeBannerIndex = 0,
    this.activeMobileBannerIndex = 0,
    this.gridProducts = const [],
    this.gridLoadedCount = 10,
    this.selectedOfferFilterId,
  });

  OfferState copyWith({
    List<OfferEntity>? offers,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasNextPage,
    OfferFilters? filters,
    int? activeBannerIndex,
    int? activeMobileBannerIndex,
    List<ProductEntity>? gridProducts,
    int? gridLoadedCount,
    String? selectedOfferFilterId,
  }) {
    return OfferState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      filters: filters ?? this.filters,
      activeBannerIndex: activeBannerIndex ?? this.activeBannerIndex,
      activeMobileBannerIndex: activeMobileBannerIndex ?? this.activeMobileBannerIndex,
      gridProducts: gridProducts ?? this.gridProducts,
      gridLoadedCount: gridLoadedCount ?? this.gridLoadedCount,
      selectedOfferFilterId: selectedOfferFilterId ?? this.selectedOfferFilterId,
    );
  }

  // Clear selected offer filter explicitly since null means "All"
  OfferState clearSelectedOfferFilterId() {
    return OfferState(
      offers: offers,
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      error: error,
      currentPage: currentPage,
      hasNextPage: hasNextPage,
      filters: filters,
      activeBannerIndex: activeBannerIndex,
      activeMobileBannerIndex: activeMobileBannerIndex,
      gridProducts: gridProducts,
      gridLoadedCount: gridLoadedCount,
      selectedOfferFilterId: null,
    );
  }
}
