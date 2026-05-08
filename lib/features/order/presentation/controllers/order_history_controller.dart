import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_order_history_usecase.dart';
import '../providers/order_providers.dart';
import '../state/order_history_state.dart';
import '../state/order_page_state.dart';

/// Controller for order history with page-based caching and duplicate fetch prevention
class OrderHistoryController extends StateNotifier<OrderHistoryState> {
  final GetOrderHistoryUseCase getOrderHistoryUseCase;
  
  // Track active fetches per page to prevent duplicates
  final Set<int> _activeFetches = {};

  OrderHistoryController(this.getOrderHistoryUseCase)
      : super(const OrderHistoryState());

  /// Load a specific page
  /// Implements duplicate fetch prevention and stale-while-revalidate
  Future<void> loadPage(int page) async {
    // Duplicate fetch prevention: ignore if already fetching
    if (_activeFetches.contains(page)) {
      debugPrint('[ORDER HISTORY] Page $page already being fetched, ignoring');
      return;
    }

    final currentPageState = state.getPage(page);
    
    // If page exists and is not stale, return immediately (no refresh needed)
    if (currentPageState != null && currentPageState.hasData && !currentPageState.isStale) {
      debugPrint('[ORDER HISTORY] Page $page is fresh, no fetch needed');
      return;
    }

    // If page exists but is stale, refresh silently (stale-while-revalidate)
    final shouldRefreshSilently = currentPageState != null && 
                                   currentPageState.hasData && 
                                   currentPageState.isStale &&
                                   !currentPageState.isRefreshing;

    if (shouldRefreshSilently) {
      debugPrint('[ORDER HISTORY] Page $page is stale, refreshing silently');
      _refreshPageSilently(page);
      return;
    }

    // Initial load: show loading state
    _activeFetches.add(page);
    
    // Update page state to loading
    final updatedPages = Map<int, OrderPageState>.from(state.pages);
    updatedPages[page] = OrderPageState(isLoading: true);
    state = state.copyWith(pages: updatedPages);

    try {
      final response = await getOrderHistoryUseCase(
        page: page,
        limit: state.limit,
        status: state.status,
        paymentStatus: state.paymentStatus,
        sortField: state.sortField,
        sortOrder: state.sortOrder,
      );

      if (!mounted) return;

      // Update page state with data
      final newPageState = OrderPageState(
        orders: response.orders,
        fetchedAt: DateTime.now(),
        isLoading: false,
      );

      final newPages = Map<int, OrderPageState>.from(state.pages);
      newPages[page] = newPageState;
      
      state = state.copyWith(
        pages: newPages,
        hasMore: response.hasMore,
      );

      debugPrint('[ORDER HISTORY] Page $page loaded successfully: ${response.orders.length} orders');
    } catch (e) {
      if (!mounted) return;

      // Update page state with error
      final errorPageState = OrderPageState(
        orders: currentPageState?.orders ?? const [],
        fetchedAt: currentPageState?.fetchedAt,
        isLoading: false,
        error: e.toString(),
      );

      final newPages = Map<int, OrderPageState>.from(state.pages);
      newPages[page] = errorPageState;
      
      state = state.copyWith(pages: newPages);
      
      debugPrint('[ORDER HISTORY] Page $page failed: $e');
    } finally {
      _activeFetches.remove(page);
    }
  }

  /// Silently refresh a stale page (stale-while-revalidate)
  Future<void> _refreshPageSilently(int page) async {
    if (_activeFetches.contains(page)) return;

    _activeFetches.add(page);
    
    final currentPageState = state.getPage(page);
    if (currentPageState == null) {
      _activeFetches.remove(page);
      return;
    }

    // Set refreshing flag
    final updatedPages = Map<int, OrderPageState>.from(state.pages);
    updatedPages[page] = currentPageState.copyWith(isRefreshing: true);
    state = state.copyWith(pages: updatedPages);

    try {
      final response = await getOrderHistoryUseCase(
        page: page,
        limit: state.limit,
        status: state.status,
        paymentStatus: state.paymentStatus,
        sortField: state.sortField,
        sortOrder: state.sortOrder,
      );

      if (!mounted) return;

      // Update page state with fresh data
      final newPageState = OrderPageState(
        orders: response.orders,
        fetchedAt: DateTime.now(),
        isRefreshing: false,
      );

      final newPages = Map<int, OrderPageState>.from(state.pages);
      newPages[page] = newPageState;
      
      state = state.copyWith(
        pages: newPages,
        hasMore: response.hasMore,
      );

      debugPrint('[ORDER HISTORY] Page $page refreshed silently');
    } catch (e) {
      if (!mounted) return;

      // On error, keep old data and clear refreshing flag
      final errorPageState = currentPageState.copyWith(
        isRefreshing: false,
        // Don't update error for silent refresh - keep old data visible
      );

      final newPages = Map<int, OrderPageState>.from(state.pages);
      newPages[page] = errorPageState;
      
      state = state.copyWith(pages: newPages);
      
      debugPrint('[ORDER HISTORY] Page $page silent refresh failed (keeping old data): $e');
    } finally {
      _activeFetches.remove(page);
    }
  }

  /// Load next page (for pagination)
  Future<void> loadNextPage() async {
    if (!state.hasMore) {
      debugPrint('[ORDER HISTORY] No more pages to load');
      return;
    }

    // Calculate next page number
    final currentPages = state.pages.keys.toList();
    final nextPage = currentPages.isEmpty ? 1 : (currentPages.reduce((a, b) => a > b ? a : b) + 1);
    
    await loadPage(nextPage);
  }

  /// Refresh all pages (user-initiated)
  Future<void> refresh() async {
    // Clear all pages and reload first page
    state = state.copyWith(pages: const {});
    await loadPage(1);
  }

  /// Clear all cached data
  void clear() {
    state = const OrderHistoryState();
    _activeFetches.clear();
  }

  /// Apply filters and refresh
  Future<void> applyFilters({
    String? status,
    String? paymentStatus,
    String? sortField,
    String? sortOrder,
  }) async {
    // Clear all pages when filters change
    state = state.copyWith(
      pages: const {},
      status: status,
      paymentStatus: paymentStatus,
      sortField: sortField,
      sortOrder: sortOrder,
    );
    _activeFetches.clear();
    await loadPage(1);
  }

  /// Clear all filters and refresh
  Future<void> clearFilters() async {
    // Clear all pages and filters
    state = const OrderHistoryState();
    _activeFetches.clear();
    await loadPage(1);
  }
}

/// Provider for order history controller
final orderHistoryControllerProvider =
    StateNotifierProvider<OrderHistoryController, OrderHistoryState>((ref) {
  final useCase = ref.read(getOrderHistoryUseCaseProvider);
  return OrderHistoryController(useCase);
});
