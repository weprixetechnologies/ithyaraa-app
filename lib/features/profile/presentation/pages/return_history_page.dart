import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/return_history_controller.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../order/presentation/pages/order_detail_page.dart';

class ReturnHistoryPage extends ConsumerWidget {
  const ReturnHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAsync = ref.watch(returnHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text('Returns & Refunds', style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: returnsAsync.when(
        data: (data) => RefreshIndicator(
          displacement: 20,
          color: Colors.black,
          onRefresh: () => ref.read(returnHistoryProvider.notifier).refresh(),
          child: data.returns.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: data.returns.length,
                  itemBuilder: (context, index) {
                    final order = data.returns[index];
                    return _SlideFadeEntrance(
                      index: index,
                      child: _buildOrderReturnCard(context, order),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => _buildErrorState(ref),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Failed to load returns', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(returnHistoryProvider.notifier).refresh(),
            child: const Text('Retry', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment_return_rounded, size: 80, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            Text('No Returns Found', style: AppTextStyles.headingSmall.copyWith(color: Colors.black87)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'You don’t have any active return or refund requests at this time.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderReturnCard(BuildContext context, order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderID}',
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(order.orderCreatedAt),
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderDetailPage(orderID: order.orderID)),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(
                      'View Order',
                      style: AppTextStyles.label.copyWith(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, thickness: 0.5),
            ),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: item.featuredImage != null
                                ? Image.network(item.featuredImage!, fit: BoxFit.cover)
                                : Container(color: Colors.grey.shade50, child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: Colors.black87)),
                              if (item.variationName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.variationName!.replaceAll('_', ' '),
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('•', style: TextStyle(color: Colors.grey.shade300)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${item.lineTotalAfter.toStringAsFixed(0)}',
                                    style: AppTextStyles.bodySmall.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildStatusBadge(item.returnStatus),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (item.returnRejectionReason != null && item.returnRejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade100.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error_outline, size: 14, color: Colors.red.shade700),
                                const SizedBox(width: 6),
                                Text('REJECTION REASON', style: AppTextStyles.label.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(item.returnRejectionReason!, style: AppTextStyles.bodySmall.copyWith(color: Colors.red.shade900, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                    if (item.returnTrackingCode != null || item.returnTrackingUrl != null) ...[
                      const SizedBox(height: 12),
                      _buildTrackingInfo(item),
                    ],
                  ],
                ),
              );
            },
          ),
          if (order.deliveredAt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Delivered on ${DateFormat('dd MMM yyyy').format(order.deliveredAt!)}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'return_requested':
        bgColor = Colors.amber;
        textColor = Colors.amber.shade900;
        label = 'Return Requested';
        icon = Icons.access_time_filled_rounded;
        break;
      case 'return_initiated':
        bgColor = Colors.blue;
        textColor = Colors.blue.shade900;
        label = 'Return Initiated';
        icon = Icons.local_shipping_rounded;
        break;
      case 'return_picked':
        bgColor = Colors.blue;
        textColor = Colors.blue.shade900;
        label = 'Return Picked';
        icon = Icons.inventory_2_rounded;
        break;
      case 'returned':
      case 'refund_completed':
      case 'replacement_complete':
        bgColor = Colors.green;
        textColor = Colors.green.shade900;
        label = status == 'refund_completed' ? 'Refund Completed' : (status == 'returned' ? 'Returned' : 'Replacement Complete');
        icon = Icons.check_circle_rounded;
        break;
      case 'returnRejected':
        bgColor = Colors.red;
        textColor = Colors.red.shade900;
        label = 'Return Rejected';
        icon = Icons.cancel_rounded;
        break;
      case 'refund_pending':
        bgColor = Colors.orange;
        textColor = Colors.orange.shade900;
        label = 'Refund Pending';
        icon = Icons.pending_rounded;
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.grey.shade900;
        label = status.replaceAll('_', ' ').toUpperCase();
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withAlpha(25),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: bgColor.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor.withAlpha(200)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo(item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.returnTrackingCode != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, size: 16, color: Colors.blue.shade800),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.blue.shade900, fontSize: 12),
                        children: [
                          const TextSpan(text: 'Tracking ID: ', style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(text: item.returnTrackingCode!, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          if (item.returnDeliveryCompany != null) TextSpan(text: '\n(${item.returnDeliveryCompany})', style: TextStyle(fontSize: 10, color: Colors.blue.shade600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (item.returnTrackingUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: InkWell(
                onTap: () {
                  // URL Launcher logic
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 26),
                    Text(
                      'TRACK PACKAGE',
                      style: AppTextStyles.label.copyWith(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new, size: 12, color: Colors.blue.shade700),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlideFadeEntrance extends StatelessWidget {
  final int index;
  final Widget child;

  const _SlideFadeEntrance({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
