import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/presale_booking_controller.dart';
import '../../domain/entities/presale_booking.dart';
import '../../../../core/theme/app_text_styles.dart';

class PresaleOrderDetailPage extends ConsumerStatefulWidget {
  final String preBookingID;

  const PresaleOrderDetailPage({super.key, required this.preBookingID});

  @override
  ConsumerState<PresaleOrderDetailPage> createState() => _PresaleOrderDetailPageState();
}

class _PresaleOrderDetailPageState extends ConsumerState<PresaleOrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(presaleBookingControllerProvider.notifier).loadBookingDetails(widget.preBookingID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(presaleBookingControllerProvider);
    final booking = state.selectedBooking;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Booking Details', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: state.isLoading && booking == null
          ? const Center(child: CircularProgressIndicator())
          : booking == null
              ? _buildErrorView()
              : _buildContent(booking),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load booking details'),
          TextButton(
            onPressed: () => ref.read(presaleBookingControllerProvider.notifier).loadBookingDetails(widget.preBookingID),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PresaleBookingEntity booking) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(booking.createdAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Booking ID', '#${booking.preBookingID}'),
                const SizedBox(height: 8),
                _buildInfoRow('Date', dateStr),
                const SizedBox(height: 8),
                _buildInfoRow('Status', booking.orderStatus.toUpperCase(), isStatus: true),
                const SizedBox(height: 8),
                _buildInfoRow('Payment', booking.paymentStatus.toUpperCase(), isStatus: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text('ITEMS', style: AppTextStyles.label.copyWith(color: Colors.grey)),
          const SizedBox(height: 12),
          if (booking.items != null)
            ...booking.items!.map((item) => _buildItemCard(item)),
          
          const SizedBox(height: 24),
          Text('SHIPPING ADDRESS', style: AppTextStyles.label.copyWith(color: Colors.grey)),
          const SizedBox(height: 12),
          if (booking.deliveryAddress != null)
            _buildAddressSection(booking.deliveryAddress!),
          
          const SizedBox(height: 24),
          Text('BILLING SUMMARY', style: AppTextStyles.label.copyWith(color: Colors.grey)),
          const SizedBox(height: 12),
          _buildSummarySection(booking),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isStatus ? _getStatusColor(value) : Colors.black,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'successful':
      case 'paid':
        return Colors.green;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildItemCard(PresaleBookingItemEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: item.featuredImage.isNotEmpty
                  ? DecorationImage(image: NetworkImage(item.featuredImage.first), fit: BoxFit.cover)
                  : null,
              color: Colors.grey.shade100,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (item.variationName != null)
                  Text(item.variationName!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 12)),
                    Text('₹${item.lineTotalAfter.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(PresaleAddressEntity address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address.line1, style: const TextStyle(fontSize: 14)),
          if (address.line2 != null) Text(address.line2!, style: const TextStyle(fontSize: 14)),
          Text('${address.city}, ${address.state} - ${address.pincode}', style: const TextStyle(fontSize: 14)),
          if (address.landmark != null) Text('Landmark: ${address.landmark}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
          if (address.phoneNumber != null) ...[
            const SizedBox(height: 8),
            Text('Contact: ${address.phoneNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySection(PresaleBookingEntity booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', booking.subtotal),
          if (booking.totalDiscount > 0) _buildPriceRow('Discount', -booking.totalDiscount, isDiscount: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('₹${booking.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            '${isDiscount ? "-" : ""}₹${price.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.green : Colors.black,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
