import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Order Status Timeline Widget
class OrderStatusTimeline extends StatelessWidget {
  final String orderStatus;
  final String paymentMode;
  final String paymentStatus;
  final DateTime? expectedDeliveryDate;
  final DateTime? returnRequestedAt;

  const OrderStatusTimeline({
    super.key,
    required this.orderStatus,
    required this.paymentMode,
    required this.paymentStatus,
    this.expectedDeliveryDate,
    this.returnRequestedAt,
  });

  @override
  Widget build(BuildContext context) {
    final stages = _getRelevantStages(orderStatus);
    final currentStageIndex = _getCurrentStageIndex(orderStatus, stages);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getHeaderText(orderStatus),
              style: AppTextStyles.headingLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: _isReturnFlow(orderStatus) ? Colors.orange.shade900 : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            _buildTimeline(currentStageIndex, stages),
          ],
        ),
      ),
    );
  }

  bool _isReturnFlow(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus.contains('return') || lowerStatus.contains('refund');
  }

  Widget _buildTimeline(int currentStageIndex, List<OrderStage> stages) {
    return Column(
      children: List.generate(stages.length, (index) {
        final stage = stages[index];
        final isActive = index == currentStageIndex;
        final isCompleted = index < currentStageIndex;
        final isLast = index == stages.length - 1;

        return _TimelineRow(
          stage: stage,
          isActive: isActive,
          isCompleted: isCompleted,
          isLast: isLast,
          orderStatus: orderStatus,
          paymentMode: paymentMode,
          paymentStatus: paymentStatus,
          expectedDeliveryDate: expectedDeliveryDate,
          returnRequestedAt: returnRequestedAt,
        );
      }),
    );
  }

  List<OrderStage> _getRelevantStages(String status) {
    if (_isReturnFlow(status)) {
      return _returnStages;
    }
    return _deliveryStages;
  }

  int _getCurrentStageIndex(String status, List<OrderStage> stages) {
    final lowerStatus = status.toLowerCase();
    
    // Check if it's a return flow
    if (_isReturnFlow(status)) {
      switch (lowerStatus) {
        case 'return_requested':
          return 0;
        case 'return_initiated':
          return 1;
        case 'return_picked':
          return 2;
        case 'return_in_transit':
          return 3;
        case 'returned':
        case 'refund_completed':
        case 'replacement_complete':
          return 4;
        case 'returnrejected':
          return 0;
        default:
          return 0;
      }
    }

    // Default delivery flow
    switch (lowerStatus) {
      case 'pending':
        return 1;
      case 'preparing':
        return 2;
      case 'shipped':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 1;
    }
  }

  String _getHeaderText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'YOUR ORDER IS PENDING';
      case 'preparing':
        return 'WE\'RE PACKING YOUR ORDER';
      case 'shipped':
        return 'YOUR ORDER IS ON ITS WAY';
      case 'delivered':
        return 'YOUR ORDER HAS BEEN DELIVERED';
      case 'cancelled':
        return 'YOUR ORDER HAS BEEN CANCELLED';
      case 'return_requested':
        return 'RETURN REQUESTED';
      case 'return_initiated':
      case 'return_picked':
        return 'RETURN IN PROGRESS';
      case 'returned':
        return 'ORDER RETURNED';
      case 'refund_completed':
        return 'REFUND COMPLETED';
      case 'returnrejected':
        return 'RETURN REJECTED';
      default:
        return status.toUpperCase().replaceAll('_', ' ');
    }
  }
}

/// Timeline Row Component
class _TimelineRow extends StatelessWidget {
  final OrderStage stage;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;
  final String orderStatus;
  final String paymentMode;
  final String paymentStatus;
  final DateTime? expectedDeliveryDate;
  final DateTime? returnRequestedAt;

  const _TimelineRow({
    required this.stage,
    required this.isActive,
    required this.isCompleted,
    required this.isLast,
    required this.orderStatus,
    required this.paymentMode,
    required this.paymentStatus,
    this.expectedDeliveryDate,
    this.returnRequestedAt,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIndicatorColumn(),
          const SizedBox(width: 16),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildIndicatorColumn() {
    bool finalIsCompleted = isCompleted;
    bool finalIsActive = isActive;

    // Special logic for payment stage: Completed only if PAID
    if (stage.type == OrderStageType.payment) {
      final status = paymentStatus.toUpperCase();
      finalIsCompleted = status.contains('PAID') || status.contains('COMPLETED') || status.contains('SUCCESS');
      finalIsActive = !finalIsCompleted;
    }

    return Column(
      children: [
        _StatusIndicator(isActive: finalIsActive, isCompleted: finalIsCompleted),
        if (!isLast)
          SizedBox(
            height: 60,
            width: 2,
            child: CustomPaint(
              painter: DashedLinePainter(
                color: finalIsCompleted ? Colors.black : Colors.grey.shade300,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    final textColor = (isActive || isCompleted)
        ? Colors.black87
        : Colors.grey.shade600;
    final fontWeight = (isActive || isCompleted)
        ? FontWeight.w700
        : FontWeight.w500;

    if (stage.type == OrderStageType.payment) {
      return _buildPaymentContent();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stage.icon, size: 24, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stage.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: fontWeight,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                if (stage.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    stage.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (stage.type == OrderStageType.delivery &&
                    (isActive || isCompleted)) ...[
                  const SizedBox(height: 8),
                  Text(
                    orderStatus.toLowerCase() == 'delivered'
                        ? (expectedDeliveryDate != null
                              ? _formatDeliveryDate(expectedDeliveryDate!)
                              : 'DELIVERED')
                        : 'Please track on delivery partner website',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
                if (stage.type == OrderStageType.returnRequested &&
                    (isActive || isCompleted) && returnRequestedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'REQUESTED ON ${_formatDeliveryDate(returnRequestedAt!)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent() {
    String label = 'Payment Pending';
    String desc = '';
    Color statusColor = Colors.grey;
    final status = paymentStatus.toUpperCase();

    if (paymentMode.toUpperCase() == 'COD') {
      label = 'Pay on Delivery';
      desc = 'Payment will be collected at delivery';
      statusColor = Colors.blue.shade700;
    } else if (status.contains('PAID') || status.contains('COMPLETED') || status.contains('SUCCESS')) {
      label = 'Payment Successfull';
      desc = 'Your payment has been confirmed';
      statusColor = Colors.green.shade700;
    } else if (status.contains('FAIL')) {
      label = 'Payment Failed';
      desc = 'Transaction was not successful';
      statusColor = Colors.red.shade700;
    } else {
      label = 'Payment Pending';
      desc = 'Waiting for payment confirmation';
      statusColor = Colors.orange.shade700;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.payment, size: 24, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeliveryDate(DateTime date) {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

/// Status Indicator Component
class _StatusIndicator extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;

  const _StatusIndicator({required this.isActive, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }

    if (isActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Dashed Line Painter
class DashedLinePainter extends CustomPainter {
  final Color color;

  const DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double y = 0;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dashHeight).clamp(0.0, size.height)),
        paint,
      );
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stage Models
enum OrderStageType { payment, pending, packing, shipping, delivery, returnRequested, returnPicked, returned }

class OrderStage {
  final OrderStageType type;
  final String label;
  final IconData icon;
  final String? description;

  const OrderStage({
    required this.type,
    required this.label,
    required this.icon,
    this.description,
  });
}

const List<OrderStage> _deliveryStages = [
  OrderStage(
    type: OrderStageType.payment,
    label: 'PAYMENT',
    icon: Icons.payment,
  ),
  OrderStage(
    type: OrderStageType.pending,
    label: 'PENDING',
    icon: Icons.access_time_outlined,
    description: 'Waiting for order approval',
  ),
  OrderStage(
    type: OrderStageType.packing,
    label: 'PACKING YOUR ORDER',
    icon: Icons.inventory_2_outlined,
    description: 'Your order will be shipped soon',
  ),
  OrderStage(
    type: OrderStageType.shipping,
    label: 'ON ITS WAY',
    icon: Icons.local_shipping_outlined,
    description: 'Use the tracking number to track your order',
  ),
  OrderStage(
    type: OrderStageType.delivery,
    label: 'DELIVERED',
    icon: Icons.check_circle_outline,
    description: 'Use the Tracking Number to Track on Delivery Partner',
  ),
];

const List<OrderStage> _returnStages = [
  OrderStage(
    type: OrderStageType.returnRequested,
    label: 'REQUEST SUBMITTED',
    icon: Icons.assignment_return_outlined,
    description: 'Your return query has been received',
  ),
  OrderStage(
    type: OrderStageType.returnRequested, // Reusing type for approval phase
    label: 'RETURN APPROVED',
    icon: Icons.fact_check_outlined,
    description: 'We have approved your return request',
  ),
  OrderStage(
    type: OrderStageType.returnPicked,
    label: 'PICKUP IN PROGRESS',
    icon: Icons.local_shipping_outlined,
    description: 'Courier partner will pick up the package soon',
  ),
  OrderStage(
    type: OrderStageType.returnPicked, // Reusing type for transit phase
    label: 'RETURN IN TRANSIT',
    icon: Icons.warehouse_outlined,
    description: 'Package is being sent to our warehouse',
  ),
  OrderStage(
    type: OrderStageType.returned,
    label: 'RETURN COMPLETED',
    icon: Icons.check_circle_outline,
    description: 'Refund or replacement has been processed',
  ),
];
