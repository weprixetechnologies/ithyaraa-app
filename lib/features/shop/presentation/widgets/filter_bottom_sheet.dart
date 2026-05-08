import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/shop_filters.dart';

/// Filter bottom sheet widget
class FilterBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final ShopFilters currentFilters;
  final Function(ShopFilters) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    this.scrollController,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ShopFilters _filters;
  Set<String> _selectedPriceBands = {};
  String? _selectedStock;
  double? _maxPriceUnder;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    // Parse existing price bands
    if (_filters.priceBands != null) {
      _selectedPriceBands = _filters.priceBands!.split(',').toSet();
    }
    _selectedStock = _filters.stock;
    _maxPriceUnder = _filters.maxPrice;
    _priceController = TextEditingController(
      text: _maxPriceUnder?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _togglePriceBand(String band) {
    setState(() {
      if (_selectedPriceBands.contains(band)) {
        _selectedPriceBands.remove(band);
      } else {
        _selectedPriceBands.add(band);
      }
    });
  }

  void _applyFilters() {
    // Optimize: Build filters explicitly to avoid copyWith null coalescing issues
    // Only join priceBands if not empty (avoid unnecessary string operation)
    final priceBandsString = _selectedPriceBands.isEmpty 
        ? null 
        : _selectedPriceBands.join(',');
    
    final updatedFilters = ShopFilters(
      // Preserve non-UI filters from current state (efficient reference copy)
      categoryIDs: _filters.categoryIDs,
      brandIDs: _filters.brandIDs,
      search: _filters.search,
      sectionid: _filters.sectionid,
      type: _filters.type,
      offerID: _filters.offerID,
      sortBy: _filters.sortBy,
      sortOrder: _filters.sortOrder,
      // Set UI-managed filters explicitly
      priceBands: priceBandsString,
      maxPrice: _maxPriceUnder,
      stock: _selectedStock,
      // Clear minPrice if priceBands are selected (they're mutually exclusive)
      minPrice: _selectedPriceBands.isNotEmpty ? null : _filters.minPrice,
    );
    
    widget.onApplyFilters(updatedFilters);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    // Optimize: Build cleared filters directly (preserve non-UI filters, clear only UI-managed ones)
    final clearedFilters = ShopFilters(
      // Preserve navigation-based filters
      categoryIDs: _filters.categoryIDs,
      brandIDs: _filters.brandIDs,
      search: _filters.search,
      sectionid: _filters.sectionid,
      type: _filters.type,
      offerID: _filters.offerID,
      sortBy: _filters.sortBy,
      sortOrder: _filters.sortOrder,
      // Clear UI-managed filters explicitly
      priceBands: null,
      maxPrice: null,
      stock: null,
      minPrice: _filters.minPrice, // Preserve if it exists (not shown in UI)
    );
    
    // Apply immediately and close (no setState needed since sheet closes)
    widget.onApplyFilters(clearedFilters);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header with Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter',
                style: AppTextStyles.headingMedium,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text(
                      'Reset',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFFE91E63),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.black87,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Price Selector (Price Bands)
          Text(
            'Price Selector',
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PriceBandChip(
                label: 'Under ₹500',
                value: 'u500',
                isSelected: _selectedPriceBands.contains('u500'),
                onTap: () => _togglePriceBand('u500'),
              ),
              _PriceBandChip(
                label: '₹500 - ₹999',
                value: '500-999',
                isSelected: _selectedPriceBands.contains('500-999'),
                onTap: () => _togglePriceBand('500-999'),
              ),
              _PriceBandChip(
                label: '₹1000 - ₹1999',
                value: '1000-1999',
                isSelected: _selectedPriceBands.contains('1000-1999'),
                onTap: () => _togglePriceBand('1000-1999'),
              ),
              _PriceBandChip(
                label: '₹2000+',
                value: '2000+',
                isSelected: _selectedPriceBands.contains('2000+'),
                onTap: () => _togglePriceBand('2000+'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Price Under
          Text(
            'Price Under',
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter max price (e.g., 5000)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixText: '₹',
            ),
            onChanged: (value) {
              setState(() {
                _maxPriceUnder = value.isEmpty
                    ? null
                    : double.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 24),
          // Stock Filter
          Text(
            'Stock',
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StockOption(
                  label: 'In Stock',
                  value: 'in',
                  isSelected: _selectedStock == 'in',
                  onTap: () {
                    setState(() {
                      _selectedStock = _selectedStock == 'in' ? null : 'in';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StockOption(
                  label: 'Out of Stock',
                  value: 'out',
                  isSelected: _selectedStock == 'out',
                  onTap: () {
                    setState(() {
                      _selectedStock = _selectedStock == 'out' ? null : 'out';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: AppTextStyles.button,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

class _PriceBandChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriceBandChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFE91E63).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFFE91E63),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? const Color(0xFFE91E63) : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

class _StockOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _StockOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE91E63).withValues(alpha: 0.2)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE91E63)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? const Color(0xFFE91E63) : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
