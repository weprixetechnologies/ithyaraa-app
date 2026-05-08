import 'order_page_state.dart';

/// Global state for order history with page-based caching
class OrderHistoryState {
  /// Map of page number to page state
  final Map<int, OrderPageState> pages;
  final bool hasMore;
  final int limit;
  final String? status;
  final String? paymentStatus;
  final String? sortField;
  final String? sortOrder;

  const OrderHistoryState({
    this.pages = const {},
    this.hasMore = true,
    this.limit = 10,
    this.status,
    this.paymentStatus,
    this.sortField,
    this.sortOrder,
  });

  OrderHistoryState copyWith({
    Map<int, OrderPageState>? pages,
    bool? hasMore,
    int? limit,
    String? status,
    String? paymentStatus,
    String? sortField,
    String? sortOrder,
  }) {
    return OrderHistoryState(
      pages: pages ?? this.pages,
      hasMore: hasMore ?? this.hasMore,
      limit: limit ?? this.limit,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
  
  /// Check if any filters are applied
  bool get hasFilters => status != null || paymentStatus != null || sortField != null || sortOrder != null;

  /// Get flattened list of all orders across all pages
  List<dynamic> get allOrders {
    final sortedPages = pages.keys.toList()..sort();
    return sortedPages
        .expand((pageNum) => pages[pageNum]!.orders)
        .toList();
  }

  /// Get state for a specific page
  OrderPageState? getPage(int page) => pages[page];

  /// Check if a page exists in cache
  bool hasPage(int page) => pages.containsKey(page) && pages[page]!.hasData;

  /// Get total number of orders loaded
  int get totalOrdersLoaded => allOrders.length;
}
