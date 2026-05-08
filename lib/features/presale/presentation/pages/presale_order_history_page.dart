import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/presale_booking_controller.dart';
import '../../domain/entities/presale_booking.dart';
import 'presale_order_detail_page.dart';
import '../../../../core/theme/app_text_styles.dart';

class PresaleOrderHistoryPage extends ConsumerWidget {
  const PresaleOrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presaleBookingControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pre-Booked History', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: state.isLoading && state.bookings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.bookings.isEmpty
              ? _buildErrorView(ref)
              : state.bookings.isEmpty
                  ? _buildEmptyView()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(presaleBookingControllerProvider.notifier).loadUserBookings(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.bookings.length,
                        itemBuilder: (context, index) {
                          final booking = state.bookings[index];
                          return _PresaleBookingCard(booking: booking);
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No pre-booked orders', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text('Your presale bookings will appear here', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load bookings'),
          TextButton(
            onPressed: () => ref.read(presaleBookingControllerProvider.notifier).loadUserBookings(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _PresaleBookingCard extends StatelessWidget {
  final PresaleBookingEntity booking;

  const _PresaleBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(booking.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PresaleOrderDetailPage(preBookingID: booking.preBookingID),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking ID: #${booking.preBookingID}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
                _buildStatusChip(booking.orderStatus),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${booking.itemCount} Item(s)', style: TextStyle(color: Colors.grey.shade600)),
                Text(
                  '₹${booking.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.payment_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Payment: ${booking.paymentStatus.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: booking.paymentStatus == 'successful' || booking.paymentStatus == 'paid'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Text('View Details', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                const Icon(Icons.chevron_right, size: 16, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'shipped':
        color = Colors.blue;
        break;
      case 'cancelled':
      case 'returned':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
