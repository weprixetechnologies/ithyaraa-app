import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_summary.dart';

/// Order card widget - displays order summary in order history list
/// Dumb widget that receives OrderSummary and displays it
class OrderCard extends StatelessWidget {
  final OrderSummaryEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  String _formatDate(DateTime date) {
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green.shade700;
      case 'returned':
      case 'cancelled':
        return Colors.red.shade700;
      case 'pending':
        return Colors.grey.shade700;
      case 'preparing':
        return Colors.yellow.shade700;
      case 'shipped':
      case 'in transit':
        return Colors.blue.shade600;
      case 'ready':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green.shade50;
      case 'returned':
      case 'cancelled':
        return Colors.red.shade50;
      case 'pending':
        return Colors.grey.shade200;
      case 'preparing':
        return Colors.yellow.shade50;
      case 'shipped':
      case 'in transit':
        return Colors.blue.shade50;
      case 'ready':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.orderStatus);
    final statusBgColor = _getStatusBackgroundColor(order.orderStatus);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Order ID, Date, and Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Order ID and Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID
                      Text(
                        'Order ID: #${order.orderID}',
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Order Date
                      Text(
                        _formatDate(order.orderCreatedAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge at top right
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatStatusText(order.orderStatus),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order Items Summary
            // Since we don't have item names in OrderSummary, we'll show item count
            // In a real scenario, you might want to fetch order details to show item names
            Text(
              '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Divider line
            Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
            const SizedBox(height: 12),

            // Footer row: Total and View Details button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Total price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${order.total.toStringAsFixed(2)}',
                      style: AppTextStyles.price.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                // View Details button
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade600,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View details',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.red.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Delivered';
      case 'shipped':
      case 'in transit':
        return 'In Transit';
      case 'cancelled':
        return 'Cancelled';
      case 'returned':
        return 'Returned';
      case 'preparing':
        return 'Preparing';
      case 'pending':
        return 'Pending';
      case 'ready':
        return 'Ready';
      default:
        return status.toUpperCase();
    }
  }
}
