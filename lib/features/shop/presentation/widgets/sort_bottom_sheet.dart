import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Sort bottom sheet widget
class SortBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final String? currentSortBy;
  final String? currentSortOrder;
  final Function(String sortBy, String sortOrder) onApplySort;

  const SortBottomSheet({
    super.key,
    this.scrollController,
    this.currentSortBy,
    this.currentSortOrder,
    required this.onApplySort,
  });

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late String selectedSortBy;
  late String selectedSortOrder;

  @override
  void initState() {
    super.initState();
    selectedSortBy = widget.currentSortBy ?? 'createdAt';
    selectedSortOrder = widget.currentSortOrder ?? 'DESC';
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
                'Sort By',
                style: AppTextStyles.headingMedium,
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
          const SizedBox(height: 24),
          // Sort By Options
          _SortOption(
            label: 'Newest First',
            sortBy: 'createdAt',
            sortOrder: 'DESC',
            isSelected: selectedSortBy == 'createdAt' &&
                selectedSortOrder == 'DESC',
            onTap: () {
              setState(() {
                selectedSortBy = 'createdAt';
                selectedSortOrder = 'DESC';
              });
            },
          ),
          const SizedBox(height: 12),
          _SortOption(
            label: 'Oldest First',
            sortBy: 'createdAt',
            sortOrder: 'ASC',
            isSelected: selectedSortBy == 'createdAt' &&
                selectedSortOrder == 'ASC',
            onTap: () {
              setState(() {
                selectedSortBy = 'createdAt';
                selectedSortOrder = 'ASC';
              });
            },
          ),
          const SizedBox(height: 12),
          _SortOption(
            label: 'Name (A-Z)',
            sortBy: 'name',
            sortOrder: 'ASC',
            isSelected: selectedSortBy == 'name' && selectedSortOrder == 'ASC',
            onTap: () {
              setState(() {
                selectedSortBy = 'name';
                selectedSortOrder = 'ASC';
              });
            },
          ),
          const SizedBox(height: 12),
          _SortOption(
            label: 'Name (Z-A)',
            sortBy: 'name',
            sortOrder: 'DESC',
            isSelected:
                selectedSortBy == 'name' && selectedSortOrder == 'DESC',
            onTap: () {
              setState(() {
                selectedSortBy = 'name';
                selectedSortOrder = 'DESC';
              });
            },
          ),
          const SizedBox(height: 12),
          _SortOption(
            label: 'Price: Low to High',
            sortBy: 'salePrice',
            sortOrder: 'ASC',
            isSelected:
                selectedSortBy == 'salePrice' && selectedSortOrder == 'ASC',
            onTap: () {
              setState(() {
                selectedSortBy = 'salePrice';
                selectedSortOrder = 'ASC';
              });
            },
          ),
          const SizedBox(height: 12),
          _SortOption(
            label: 'Price: High to Low',
            sortBy: 'salePrice',
            sortOrder: 'DESC',
            isSelected:
                selectedSortBy == 'salePrice' && selectedSortOrder == 'DESC',
            onTap: () {
              setState(() {
                selectedSortBy = 'salePrice';
                selectedSortOrder = 'DESC';
              });
            },
          ),
          const SizedBox(height: 24),
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApplySort(selectedSortBy, selectedSortOrder);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply',
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

class _SortOption extends StatelessWidget {
  final String label;
  final String sortBy;
  final String sortOrder;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.sortBy,
    required this.sortOrder,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? const Color(0xFFE91E63)
                      : Colors.black87,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFE91E63),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
