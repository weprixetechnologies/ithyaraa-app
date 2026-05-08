import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_summary.dart';
import '../controllers/order_history_controller.dart';
import '../state/order_history_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_skeleton_card.dart';
import '../widgets/order_sort_bottom_sheet.dart';
import 'order_detail_page.dart';
import 'order_search_page.dart';

/// Order History Page
///
/// Features:
/// - Page-based pagination with Riverpod state management
/// - Visit-scoped caching (90 seconds stale-while-revalidate)
/// - Duplicate fetch prevention
/// - Infinite scroll (loads next page at 80% scroll)
/// - Inline error handling with retry
class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load first page on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderHistoryControllerProvider.notifier).loadPage(1);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load next page when scrolled to 80%
    if (currentScroll >= maxScroll * 0.8) {
      final state = ref.read(orderHistoryControllerProvider);
      if (state.hasMore) {
        ref.read(orderHistoryControllerProvider.notifier).loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderHistoryState = ref.watch(orderHistoryControllerProvider);
    final allOrders = orderHistoryState.allOrders;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black87,
        ),
        title: Text('Order History', style: AppTextStyles.headingMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showSortBottomSheet(context),
            color: Colors.black87,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await ref.read(orderHistoryControllerProvider.notifier).refresh();
            },
            child: Column(
              children: [
                // Search box - visual affordance that navigates to search screen
                _buildSearchBox(),
                // Status filter pills (client-side for quick filtering)
                _buildStatusFilters(orderHistoryState),
                Expanded(child: _buildContent(orderHistoryState, allOrders)),
              ],
            ),
          ),
          // Floating Clear Filter button
          if (orderHistoryState.hasFilters)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildClearFilterButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(OrderHistoryState state, List<dynamic> allOrders) {
    // Orders are already filtered and sorted server-side
    final filteredOrders = allOrders;

    // Check if first page is loading
    final firstPageState = state.getPage(1);
    final isInitialLoading = firstPageState?.isLoading ?? false;

    // If initial loading and no data, show skeletons
    if (isInitialLoading && allOrders.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 3, // Show 3 skeleton cards
        itemBuilder: (context, index) => const OrderSkeletonCard(),
      );
    }

    // If no orders and not loading, show empty state
    if (filteredOrders.isEmpty && !isInitialLoading) {
      final hasFilters = state.hasFilters;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No orders found' : 'No orders yet',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters'
                  : 'Your order history will appear here',
              style: AppTextStyles.description.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Build list with filtered orders
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredOrders.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end if there's more to load
        if (index >= filteredOrders.length) {
          // Check if next page is loading
          final nextPageNum = (state.pages.keys.isEmpty
              ? 1
              : state.pages.keys.reduce((a, b) => a > b ? a : b) + 1);
          final nextPageState = state.getPage(nextPageNum);
          final isLoadingNext = nextPageState?.isLoading ?? false;

          if (isLoadingNext) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return const SizedBox.shrink();
        }

        final order = filteredOrders[index] as OrderSummaryEntity;

        // Check for errors in the page this order belongs to
        // Find which page this order is on (in original allOrders list)
        int orderPage = 1;
        int orderIndex = 0;
        final originalIndex = allOrders.indexOf(order);
        for (final pageNum in state.pages.keys.toList()..sort()) {
          final pageOrders = state.pages[pageNum]!.orders;
          if (orderIndex + pageOrders.length > originalIndex) {
            orderPage = pageNum;
            break;
          }
          orderIndex += pageOrders.length;
        }

        final pageState = state.getPage(orderPage);
        final hasError = pageState?.error != null;
        final isLastOrderInPage =
            index == filteredOrders.length - 1 &&
            originalIndex == allOrders.length - 1;

        return Column(
          children: [
            OrderCard(
              order: order,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderDetailPage(orderID: order.orderID),
                  ),
                );
              },
            ),
            // Show inline error for this page if it exists and this is the last order in the page
            if (hasError && isLastOrderInPage)
              _buildErrorWidget(pageState!.error!, orderPage),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(String error, int page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Failed to load orders',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(orderHistoryControllerProvider.notifier)
                      .loadPage(page);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Search box widget - visual affordance that navigates to search screen
  /// This is NOT a functional search field on this screen
  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderSearchPage()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 12),
              Text(
                'Search by order ID or item',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Status filter pills (All Orders, Delivered, In Transit, etc.)
  /// These are for quick client-side filtering, but server-side filters take precedence
  Widget _buildStatusFilters(OrderHistoryState state) {
    final filters = ['All Orders', 'Delivered', 'In Transit', 'Cancelled'];

    // Determine selected filter based on server-side status
    // Note: API uses lowercase values: "pending", "preparing", "shipped", "delivered", "cancelled", "returned"
    String selectedFilter = 'All Orders';
    if (state.status != null) {
      switch (state.status!.toLowerCase()) {
        case 'delivered':
          selectedFilter = 'Delivered';
          break;
        case 'shipped':
          selectedFilter = 'In Transit';
          break;
        case 'cancelled':
          selectedFilter = 'Cancelled';
          break;
        case 'preparing':
        case 'pending':
        case 'returned':
          // These statuses don't have quick filter pills, so show "All Orders"
          selectedFilter = 'All Orders';
          break;
        default:
          selectedFilter = 'All Orders';
      }
    }

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                // When "All Orders" is clicked, clear all filters
                if (filter == 'All Orders') {
                  ref
                      .read(orderHistoryControllerProvider.notifier)
                      .clearFilters();
                } else {
                  // Apply server-side filter with exact API status values (all lowercase)
                  String? status;
                  switch (filter) {
                    case 'Delivered':
                      status = 'delivered';
                      break;
                    case 'In Transit':
                      status = 'shipped';
                      break;
                    case 'Cancelled':
                      status = 'cancelled';
                      break;
                    default:
                      status = null;
                  }
                  ref
                      .read(orderHistoryControllerProvider.notifier)
                      .applyFilters(
                        status: status,
                        paymentStatus: state.paymentStatus,
                        sortField: state.sortField,
                        sortOrder: state.sortOrder,
                      );
                }
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.red.shade600,
              side: BorderSide(
                color: isSelected ? Colors.red.shade600 : Colors.grey.shade300,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  /// Show filter and sort bottom sheet
  void _showSortBottomSheet(BuildContext context) {
    final state = ref.read(orderHistoryControllerProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => OrderSortBottomSheet(
          scrollController: scrollController,
          currentStatus: state.status,
          currentPaymentStatus: state.paymentStatus,
          currentSortField: state.sortField,
          currentSortOrder: state.sortOrder,
          onApplyFilters: (status, paymentStatus, sortField, sortOrder) {
            ref
                .read(orderHistoryControllerProvider.notifier)
                .applyFilters(
                  status: status,
                  paymentStatus: paymentStatus,
                  sortField: sortField,
                  sortOrder: sortOrder,
                );
          },
        ),
      ),
    );
  }

  /// Build floating clear filter button
  Widget _buildClearFilterButton() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: () {
            ref.read(orderHistoryControllerProvider.notifier).clearFilters();
          },
          icon: const Icon(Icons.clear_all, size: 20),
          label: Text(
            'Clear Filter',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red.shade600,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.shade600, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
