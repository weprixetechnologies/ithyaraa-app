import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_summary.dart';
import '../providers/order_providers.dart';
import '../widgets/order_card.dart';
import 'order_detail_page.dart';

/// Order Search Page
///
/// Features:
/// - Fully isolated from Order History (no shared state)
/// - Auto-focused search input with keyboard open
/// - Debounced search (500ms)
/// - Local state management (setState only)
/// - Uses orderID query parameter for API search
/// - No pagination (single page results)
class OrderSearchPage extends ConsumerStatefulWidget {
  const OrderSearchPage({super.key});

  @override
  ConsumerState<OrderSearchPage> createState() => _OrderSearchPageState();
}

class _OrderSearchPageState extends ConsumerState<OrderSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  // Local state - completely isolated from Order History
  List<OrderSummaryEntity> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus search input after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Debounced search handler
  /// Only fires API call after 500ms of no typing
  void _onSearchChanged(String query) {
    _currentQuery = query;
    
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear results immediately if query is empty
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    // Set loading state immediately for better UX
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Debounce: wait 500ms before making API call
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  /// Perform actual API search
  /// Uses orderID query parameter to search for specific order
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    // Only update if query hasn't changed (prevent race conditions)
    if (query != _currentQuery.trim()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final useCase = ref.read(getOrderHistoryUseCaseProvider);
      
      // Search using orderID parameter (page 1, limit 10)
      final response = await useCase(
        page: 1,
        limit: 10,
        orderID: query, // Pass query as orderID parameter
      );

      if (!mounted) return;

      // Only update if query still matches (prevent stale results)
      if (query == _currentQuery.trim()) {
        setState(() {
          _searchResults = response.orders;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      // Only update if query still matches
      if (query == _currentQuery.trim()) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
          _searchResults = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black87,
        ),
        title: Text(
          'Search Order History',
          style: AppTextStyles.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search input box
          _buildSearchInput(),
          // Search results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  /// Search input widget with auto-focus
  Widget _buildSearchInput() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter order ID...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 20,
          ),
        ),
        style: AppTextStyles.bodyMedium,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          // Cancel debounce and search immediately on submit
          _debounceTimer?.cancel();
          _performSearch(query.trim());
        },
      ),
    );
  }

  /// Build search results based on current state
  Widget _buildSearchResults() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to search orders',
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.description.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_currentQuery.trim().isNotEmpty) {
                    _performSearch(_currentQuery.trim());
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty query state
    if (_currentQuery.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for orders',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter an order ID to search',
              style: AppTextStyles.description.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // No results state
    if (_searchResults.isEmpty) {
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
              'No orders found',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different order ID',
              style: AppTextStyles.description.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Results list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final order = _searchResults[index];
        return OrderCard(
          order: order,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(orderID: order.orderID),
              ),
            );
          },
        );
      },
    );
  }
}
