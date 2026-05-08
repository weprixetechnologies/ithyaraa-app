import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Sort option for order history
enum OrderSortOption {
  newestFirst,
  oldestFirst,
  totalHighToLow,
  totalLowToHigh,
}

/// Filter and sort bottom sheet widget for order history
class OrderSortBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final String? currentStatus;
  final String? currentPaymentStatus;
  final String? currentSortField;
  final String? currentSortOrder;
  final Function(String? status, String? paymentStatus, String? sortField, String? sortOrder) onApplyFilters;

  const OrderSortBottomSheet({
    super.key,
    this.scrollController,
    this.currentStatus,
    this.currentPaymentStatus,
    this.currentSortField,
    this.currentSortOrder,
    required this.onApplyFilters,
  });

  @override
  State<OrderSortBottomSheet> createState() => _OrderSortBottomSheetState();
}

class _OrderSortBottomSheetState extends State<OrderSortBottomSheet> {
  String? selectedStatus;
  String? selectedPaymentStatus;
  String? selectedSortField;
  String? selectedSortOrder;

  @override
  void initState() {
    super.initState();
    // Reset to defaults if no filters are applied
    selectedStatus = widget.currentStatus;
    selectedPaymentStatus = widget.currentPaymentStatus;
    selectedSortField = widget.currentSortField ?? 'createdAt';
    selectedSortOrder = widget.currentSortOrder ?? 'desc';
  }
  
  @override
  void didUpdateWidget(OrderSortBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selections if filters were cleared externally
    if (widget.currentStatus != oldWidget.currentStatus ||
        widget.currentPaymentStatus != oldWidget.currentPaymentStatus ||
        widget.currentSortField != oldWidget.currentSortField ||
        widget.currentSortOrder != oldWidget.currentSortOrder) {
      setState(() {
        selectedStatus = widget.currentStatus;
        selectedPaymentStatus = widget.currentPaymentStatus;
        selectedSortField = widget.currentSortField ?? 'createdAt';
        selectedSortOrder = widget.currentSortOrder ?? 'desc';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Close Button (Fixed at top)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort',
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
          ),
          // Scrollable Filters Section
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter Section
                  Text(
                    'Status',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(
                        label: 'All',
                        value: null,
                        isSelected: selectedStatus == null,
                        onTap: () {
                          setState(() {
                            selectedStatus = null;
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Pending',
                        value: 'pending',
                        isSelected: selectedStatus == 'pending',
                        onTap: () {
                          setState(() {
                            selectedStatus = 'pending';
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Preparing',
                        value: 'preparing',
                        isSelected: selectedStatus == 'preparing',
                        onTap: () {
                          setState(() {
                            selectedStatus = 'preparing';
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Shipped',
                        value: 'shipped',
                        isSelected: selectedStatus == 'shipped',
                        onTap: () {
                          setState(() {
                            selectedStatus = 'shipped';
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Delivered',
                        value: 'delivered',
                        isSelected: selectedStatus == 'delivered',
                        onTap: () {
                          setState(() {
                            selectedStatus = 'delivered';
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Cancelled',
                        value: 'cancelled',
                        isSelected: selectedStatus == 'cancelled',
                        onTap: () {
                          setState(() {
                            selectedStatus = 'cancelled';
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Returned',
                        value: 'returned',
                        isSelected: selectedStatus == 'returned',
                        onTap: () {
                          setState(() {
                            selectedStatus = 'returned';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment Status Filter Section
                  Text(
                    'Payment Status',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(
                        label: 'All',
                        value: null,
                        isSelected: selectedPaymentStatus == null,
                        onTap: () {
                          setState(() {
                            selectedPaymentStatus = null;
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Pending',
                        value: 'pending',
                        isSelected: selectedPaymentStatus == 'pending',
                        onTap: () {
                          setState(() {
                            selectedPaymentStatus = 'pending';
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Successful',
                        value: 'successful',
                        isSelected: selectedPaymentStatus == 'successful',
                        onTap: () {
                          setState(() {
                            selectedPaymentStatus = 'successful';
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Failed',
                        value: 'failed',
                        isSelected: selectedPaymentStatus == 'failed',
                        onTap: () {
                          setState(() {
                            selectedPaymentStatus = 'failed';
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Refunded',
                        value: 'refunded',
                        isSelected: selectedPaymentStatus == 'refunded',
                        onTap: () {
                          setState(() {
                            selectedPaymentStatus = 'refunded';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sort Section
                  Text(
                    'Sort By',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Newest First',
                    icon: Icons.access_time,
                    sortField: 'createdAt',
                    sortOrder: 'desc',
                    isSelected: selectedSortField == 'createdAt' && selectedSortOrder == 'desc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'createdAt';
                        selectedSortOrder = 'desc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Oldest First',
                    icon: Icons.history,
                    sortField: 'createdAt',
                    sortOrder: 'asc',
                    isSelected: selectedSortField == 'createdAt' && selectedSortOrder == 'asc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'createdAt';
                        selectedSortOrder = 'asc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Total: High to Low',
                    icon: Icons.arrow_downward,
                    sortField: 'total',
                    sortOrder: 'desc',
                    isSelected: selectedSortField == 'total' && selectedSortOrder == 'desc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'total';
                        selectedSortOrder = 'desc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Total: Low to High',
                    icon: Icons.arrow_upward,
                    sortField: 'total',
                    sortOrder: 'asc',
                    isSelected: selectedSortField == 'total' && selectedSortOrder == 'asc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'total';
                        selectedSortOrder = 'asc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Order ID: A-Z',
                    icon: Icons.tag,
                    sortField: 'orderID',
                    sortOrder: 'asc',
                    isSelected: selectedSortField == 'orderID' && selectedSortOrder == 'asc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'orderID';
                        selectedSortOrder = 'asc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Order ID: Z-A',
                    icon: Icons.tag,
                    sortField: 'orderID',
                    sortOrder: 'desc',
                    isSelected: selectedSortField == 'orderID' && selectedSortOrder == 'desc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'orderID';
                        selectedSortOrder = 'desc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Payment Mode: A-Z',
                    icon: Icons.payment,
                    sortField: 'paymentMode',
                    sortOrder: 'asc',
                    isSelected: selectedSortField == 'paymentMode' && selectedSortOrder == 'asc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'paymentMode';
                        selectedSortOrder = 'asc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Payment Mode: Z-A',
                    icon: Icons.payment,
                    sortField: 'paymentMode',
                    sortOrder: 'desc',
                    isSelected: selectedSortField == 'paymentMode' && selectedSortOrder == 'desc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'paymentMode';
                        selectedSortOrder = 'desc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Payment Status: A-Z',
                    icon: Icons.account_balance_wallet,
                    sortField: 'paymentStatus',
                    sortOrder: 'asc',
                    isSelected: selectedSortField == 'paymentStatus' && selectedSortOrder == 'asc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'paymentStatus';
                        selectedSortOrder = 'asc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Payment Status: Z-A',
                    icon: Icons.account_balance_wallet,
                    sortField: 'paymentStatus',
                    sortOrder: 'desc',
                    isSelected: selectedSortField == 'paymentStatus' && selectedSortOrder == 'desc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'paymentStatus';
                        selectedSortOrder = 'desc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Order Status: A-Z',
                    icon: Icons.receipt_long,
                    sortField: 'orderStatus',
                    sortOrder: 'asc',
                    isSelected: selectedSortField == 'orderStatus' && selectedSortOrder == 'asc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'orderStatus';
                        selectedSortOrder = 'asc';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    label: 'Order Status: Z-A',
                    icon: Icons.receipt_long,
                    sortField: 'orderStatus',
                    sortOrder: 'desc',
                    isSelected: selectedSortField == 'orderStatus' && selectedSortOrder == 'desc',
                    onTap: () {
                      setState(() {
                        selectedSortField = 'orderStatus';
                        selectedSortOrder = 'desc';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Apply Button (Fixed at bottom, outside scrollview)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(
                      selectedStatus,
                      selectedPaymentStatus,
                      selectedSortField,
                      selectedSortOrder,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status chip widget
class _StatusChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
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
      backgroundColor: Colors.white,
      selectedColor: Colors.red.shade50,
      side: BorderSide(
        color: isSelected ? Colors.red.shade600 : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? Colors.red.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

/// Individual sort option widget
class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String sortField;
  final String sortOrder;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.sortField,
    required this.sortOrder,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.red.shade600 : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? Colors.red.shade700 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.red.shade600,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
