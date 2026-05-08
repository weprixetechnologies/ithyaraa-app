import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/combo_item.dart';
import '../providers/order_providers.dart';
import '../widgets/shipping_address_widget.dart';
import '../widgets/order_status_timeline.dart';
import '../widgets/return_request_bottom_sheet.dart';

/// Order Detail Page
///
/// Features:
/// - No Riverpod state management (uses Riverpod only to get use case)
/// - Fetches data in initState using authenticated Dio
/// - Shows loading → success → error states
/// - Full error UI with retry
/// - Beautiful UI matching the design
class OrderDetailPage extends ConsumerStatefulWidget {
  final String orderID; // Alphanumeric order ID

  const OrderDetailPage({super.key, required this.orderID});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  OrderDetailEntity? _orderDetail;
  bool _isLoading = true;
  String? _error;
  bool _isSendingInvoice = false;
  String? _invoiceMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrderDetail();
    });
  }

  Future<void> _fetchOrderDetail({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final useCase = ref.read(getOrderDetailUseCaseProvider);
      final orderDetail = await useCase(widget.orderID);

      if (!mounted) return;

      setState(() {
        _orderDetail = orderDetail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Order Detail', style: AppTextStyles.headingMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_orderDetail == null) {
      return const Center(child: Text('No order data available'));
    }

    final isPending =
        _orderDetail!.paymentStatus.toUpperCase() == 'PENDING' ||
        _orderDetail!.paymentStatus.toUpperCase() == 'INITIATED';

    // Extract shipping address from first item
    final firstItem = _orderDetail!.items.isNotEmpty
        ? _orderDetail!.items.first
        : null;
    final shippingAddress = firstItem?.shippingAddress;
    final email = firstItem?.email;
    final contactNumber = firstItem?.contactNumber;
    // Parse values from API response if available
    double itemTotal = 0.0;
    double totalDiscount = 0.0;
    double subtotal = 0.0;
    double shipping = 0.0;
    double handlingFee = 0.0;
    double couponDiscount = 0.0;
    double paidWallet = 0.0;
    final total = _orderDetail!.total;

    final orderMeta = _orderDetail!.orderMeta;
    if (orderMeta != null) {
      double parseOrderDouble(String key) {
        final val = orderMeta[key];
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val) ?? 0.0;
        return 0.0;
      }

      itemTotal = parseOrderDouble('itemTotal');
      totalDiscount = parseOrderDouble('totalDiscount');
      subtotal = parseOrderDouble('subtotal');
      shipping = parseOrderDouble('shippingFee');
      couponDiscount = parseOrderDouble('couponDiscount');
      paidWallet = parseOrderDouble('paidWallet');

      final dynamic hf = orderMeta['handlingFee'];
      if (hf == true || hf == 1 || hf == '1') {
        handlingFee = parseOrderDouble('handFeeRate');
      } else if (hf is num || hf is String) {
        handlingFee = parseOrderDouble('handlingFee');
      }
    } else {
      for (final item in _orderDetail!.items) {
        subtotal += (item.lineTotalAfter ?? item.price);
      }
      handlingFee = total - subtotal - shipping;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPending)
            _PollingBanner(
              onRefresh: () => _fetchOrderDetail(isBackground: true),
            ),
          // Order Status Timeline
          OrderStatusTimeline(
            orderStatus: _getEffectiveStatus(_orderDetail!),
            paymentMode: _orderDetail!.paymentMode,
            paymentStatus: _orderDetail!.paymentStatus,
            expectedDeliveryDate: _calculateExpectedDeliveryDate(_orderDetail!),
            returnRequestedAt: _orderDetail!.items
                .where((item) => item.returnRequestedAt != null)
                .firstOrNull
                ?.returnRequestedAt,
          ),

          // Order Summary Card (with products - second)
          _buildOrderSummaryCard(
            _orderDetail!,
            itemTotal,
            totalDiscount,
            subtotal,
            shipping,
            handlingFee,
            couponDiscount,
            paidWallet,
          ),

          // Delivery Address Section (if available)
          if (shippingAddress != null && shippingAddress.isNotEmpty)
            ShippingAddressWidget(
              shippingAddress: shippingAddress,
              email: email,
              contactNumber: contactNumber,
            ),

          // Payment Information Card
          _buildPaymentInformationCard(_orderDetail!),

          // Send Invoice Email Button
          _buildSendInvoiceButton(_orderDetail!),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load order',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              style: AppTextStyles.description.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchOrderDetail,
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

  Widget _buildPaymentInformationCard(OrderDetailEntity order) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Icon(
                  Icons.payment_outlined,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Payment Information', style: AppTextStyles.headingSmall),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Method
            _buildInfoRow('Payment Method:', order.paymentMode),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment Status:', style: AppTextStyles.bodyMedium),
                const SizedBox(width: 8),
                _buildPaymentStatusBadge(order),
              ],
            ),
            const SizedBox(height: 12),

            // Order Date
            _buildInfoRow('Order Date:', _formatDate(order.orderCreatedAt)),
          ],
        ),
      ),
    );
  }

  DateTime? _calculateExpectedDeliveryDate(OrderDetailEntity order) {
    // Calculate expected delivery date (e.g., 3-5 days from order date)
    // You can adjust this logic based on your business rules
    if (order.orderStatus.toLowerCase() == 'shipped' ||
        order.orderStatus.toLowerCase() == 'delivered') {
      return order.orderCreatedAt.add(const Duration(days: 3));
    }
    return null;
  }

  Widget _buildOrderSummaryCard(
    OrderDetailEntity order,
    double itemTotal,
    double totalDiscount,
    double subtotal,
    double shipping,
    double handlingFee,
    double couponDiscount,
    double paidWallet,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Order Summary', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),

            // Items List
            ...order.items.map((item) => _buildOrderItemRow(item)),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Price Breakdown
            if (itemTotal > 0) ...[
              _buildPriceRow('Item Total:', '₹${itemTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
            ],
            if (totalDiscount > 0) ...[
              _buildPriceRow(
                'Item Discount:',
                '-₹${totalDiscount.toStringAsFixed(2)}',
                valueColor: Colors.green.shade600,
              ),
              const SizedBox(height: 8),
            ],
            _buildPriceRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildPriceRow(
              'Shipping:',
              shipping == 0 ? 'Free' : '₹${shipping.toStringAsFixed(2)}',
            ),
            if (handlingFee > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Handling Fee (COD):',
                '₹${handlingFee.toStringAsFixed(2)}',
              ),
            ],
            if (couponDiscount > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Coupon Discount:',
                '-₹${couponDiscount.toStringAsFixed(2)}',
                valueColor: Colors.green.shade600,
              ),
            ],
            if (paidWallet > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Paid from Wallet:',
                '-₹${paidWallet.toStringAsFixed(2)}',
                valueColor: Colors.green.shade600,
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '₹${order.total.toStringAsFixed(2)}',
                  style: AppTextStyles.price.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItemEntity item) {
    final itemTotal = item.lineTotalAfter ?? item.price;
    final hasTrackingInfo =
        item.trackingCode != null || item.deliveryCompany != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      item.productName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Variation Values (key-value pairs)
                    if (item.variationValues != null &&
                        item.variationValues!.isNotEmpty)
                      ...item.variationValues!.expand((variationMap) {
                        return variationMap.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        });
                      }),
                    // Fallback to storedVariationName if variationValues is not available
                    if ((item.variationValues == null ||
                            item.variationValues!.isEmpty) &&
                        item.storedVariationName != null &&
                        item.storedVariationName!.isNotEmpty)
                      Text(
                        item.storedVariationName!.replaceAll('_', ' '),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),

                    // Return Status Badge for Item
                    if (item.returnStatus != null &&
                        item.returnStatus!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildItemReturnStatusBadge(item.returnStatus!),
                    ],
                  ],
                ),
              ),

              // Price Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${itemTotal.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Quantity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Qty: ${item.quantity}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Combo Items Section: Nested items for combo products (pre-defined and make-combo)
          // Rendered after main product info, before custom inputs and tracking
          if (item.comboItems != null && item.comboItems!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildComboItemsSection(item.comboItems!),
          ],

          // Custom Inputs Section: User-provided custom data (text, images, etc.)
          // Rendered after combo items (if any), before tracking details
          if (item.customInputs != null && item.customInputs!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCustomInputsSection(item.customInputs!),
          ],

          // Tracking Details Section
          if (hasTrackingInfo) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Delivery Tracking',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (item.trackingCode != null &&
                      item.trackingCode!.isNotEmpty) ...[
                    _buildTrackingRow('Tracking Code:', item.trackingCode!),
                    const SizedBox(height: 6),
                  ],
                  if (item.deliveryCompany != null &&
                      item.deliveryCompany!.isNotEmpty) ...[
                    _buildTrackingRow(
                      'Delivery Company:',
                      item.deliveryCompany!,
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Return Tracking Details Section
          if (item.returnTrackingCode != null ||
              item.returnTrackingUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_return_outlined,
                        size: 16,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Return Tracking',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (item.returnTrackingCode != null &&
                      item.returnTrackingCode!.isNotEmpty) ...[
                    _buildTrackingRow(
                      'Return Tracking ID:',
                      item.returnTrackingCode!,
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (item.returnDeliveryCompany != null) ...[
                    _buildTrackingRow(
                      'Delivery Company:',
                      item.returnDeliveryCompany!,
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (item.returnTrackingUrl != null)
                    GestureDetector(
                      onTap: () {
                        // URL Launcher
                      },
                      child: Text(
                        'Track return package →',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  if (item.returnRejectionReason != null &&
                      item.returnRejectionReason!.isNotEmpty) ...[
                    const Divider(height: 16),
                    Text(
                      'Rejection Reason: ${item.returnRejectionReason}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Return Item Button
          if (_canReturnItem(item)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showReturnBottomSheet(item),
                icon: const Icon(Icons.assignment_return_outlined, size: 18),
                label: const Text('Return Item'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  /// Combo Items Section Widget
  ///
  /// Renders nested combo sub-items under the main product.
  /// Handles both pre-defined combos and make-combo products identically.
  ///
  /// Display rules:
  /// - Visually indented with left padding/border
  /// - Preceded by "Includes:" label
  /// - Shows: image, name, brand (if present), variation (if present)
  /// - Does NOT show: quantity, unit price, total price (read-only display)
  Widget _buildComboItemsSection(List<ComboItemEntity> comboItems) {
    return Container(
      // margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Includes:" label
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Includes:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Combo sub-items list
          ...comboItems.map((comboItem) => _buildComboSubItem(comboItem)),
        ],
      ),
    );
  }

  /// Combo Sub-Item Widget
  ///
  /// Renders a single combo sub-item with:
  /// - Image (smaller, 60x60)
  /// - Name
  /// - Brand name (if present)
  /// - Variation name (if present)
  ///
  /// Does NOT show quantity, prices (read-only display)
  Widget _buildComboSubItem(ComboItemEntity comboItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combo sub-item image (smaller than main product)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: comboItem.imageUrl != null
                ? Image.network(
                    comboItem.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildComboPlaceholderImage();
                    },
                  )
                : _buildComboPlaceholderImage(),
          ),
          const SizedBox(width: 10),
          // Combo sub-item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand name (if present) - shown first for combo sub-items
                if (comboItem.brand != null && comboItem.brand!.isNotEmpty) ...[
                  Text(
                    comboItem.brand!.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                // Product name (ComboItemEntity uses "name" not "productName")
                Text(
                  comboItem.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Variation Values (key-value pairs) - combo sub-items
                if (comboItem.variationValues != null &&
                    comboItem.variationValues!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ...comboItem.variationValues!.expand((variationMap) {
                    return variationMap.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      );
                    });
                  }),
                ]
                // Fallback to variationName if variationValues is not available
                else if (comboItem.variationName != null &&
                    comboItem.variationName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    comboItem.variationName!.replaceAll('_', ' '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 11,
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

  /// Placeholder image for combo sub-items (smaller)
  Widget _buildComboPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  /// Custom Inputs Section Widget
  ///
  /// Renders user-provided custom product inputs.
  /// Supports mixed text and image inputs.
  ///
  /// Display rules:
  /// - Label: "Custom Details:"
  /// - Text values: show key + value
  /// - Image URLs: render image preview
  /// - Detects images by: URL containing "customer-upload", image extensions (jpg, png, webp)
  Widget _buildCustomInputsSection(Map<String, dynamic> customInputs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Custom Details:" label
          Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 14,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Custom Details:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Render each custom input
          ...customInputs.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;
            return _buildCustomInputItem(key, value);
          }),
        ],
      ),
    );
  }

  /// Custom Input Item Widget
  ///
  /// Renders a single custom input entry.
  /// Detects if value is an image URL and renders accordingly.
  Widget _buildCustomInputItem(String key, dynamic value) {
    // Check if value is an image URL
    final isImage = _isImageUrl(value?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key label
          Text(
            key.replaceAll('_', ' ').toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          // Value: image or text
          if (isImage)
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                value.toString(),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 32,
                    ),
                  );
                },
              ),
            )
          else
            // Text value
            Text(
              value?.toString() ?? '',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade800,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  /// Helper: Check if a string is an image URL
  ///
  /// Detects images by:
  /// - URL containing "customer-upload"
  /// - Image file extensions: jpg, jpeg, png, webp, gif
  bool _isImageUrl(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('customer-upload') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.endsWith('.gif') ||
        lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.webp') ||
        lowerUrl.contains('.gif');
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(color: valueColor),
        ),
      ],
    );
  }

  Future<void> _sendInvoiceEmail(String orderID) async {
    setState(() {
      _isSendingInvoice = true;
      _invoiceMessage = null;
    });

    try {
      final useCase = ref.read(sendInvoiceEmailUseCaseProvider);
      await useCase(orderID);

      if (!mounted) return;

      setState(() {
        _isSendingInvoice = false;
        _invoiceMessage = 'Invoice email sent successfully!';
      });

      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _invoiceMessage = null;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSendingInvoice = false;
        _invoiceMessage = 'Failed to send invoice: ${e.toString()}';
      });
    }
  }

  Widget _buildSendInvoiceButton(OrderDetailEntity order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Success/Error Message
          if (_invoiceMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _invoiceMessage!.contains('successfully')
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _invoiceMessage!.contains('successfully')
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _invoiceMessage!.contains('successfully')
                        ? Icons.check_circle
                        : Icons.error_outline,
                    color: _invoiceMessage!.contains('successfully')
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _invoiceMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _invoiceMessage!.contains('successfully')
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Send Invoice Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSendingInvoice
                  ? null
                  : () => _sendInvoiceEmail(order.orderID),
              icon: _isSendingInvoice
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.email_outlined),
              label: Text(
                _isSendingInvoice ? 'Sending Invoice...' : 'Send Invoice Email',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final hour = date.hour;
    final minute = date.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '${date.day} ${months[date.month - 1]} ${date.year} at $displayHour:${minute.toString().padLeft(2, '0')} $amPm';
  }

  bool _canReturnItem(OrderItemEntity item) {
    // 1. Order status must be delivered or partially_returned
    final orderStatus = _orderDetail?.orderStatus.toLowerCase();
    if (orderStatus != 'delivered' && orderStatus != 'partially_returned') {
      return false;
    }

    // 2. Item must be delivered
    if (item.itemStatus?.toLowerCase() != 'delivered') {
      return false;
    }

    // 3. Item must not already be in return process
    if (item.returnStatus != null &&
        item.returnStatus != 'none' &&
        item.returnStatus != '') {
      return false;
    }

    // 4. Return window (7 days)
    final deliveredAt = _orderDetail?.deliveredAt;
    if (deliveredAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(deliveredAt).inDays;
    return difference <= 7;
  }

  void _showReturnBottomSheet(OrderItemEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReturnRequestBottomSheet(
        item: item,
        onSuccess: () {
          // Refresh order details to show new return status
          _fetchOrderDetail();
        },
      ),
    );
  }
}

class _PollingBanner extends StatefulWidget {
  final VoidCallback onRefresh;

  const _PollingBanner({required this.onRefresh});

  @override
  State<_PollingBanner> createState() => _PollingBannerState();
}

class _PollingBannerState extends State<_PollingBanner> {
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _countdownSeconds = 10;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _countdownSeconds = 10;
        }
      });
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) return;
      widget.onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Pending',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  'Waiting for payment confirmation...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_countdownSeconds}s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPaymentStatusBadge(OrderDetailEntity order) {
  Color bgColor = Colors.grey.shade300;
  Color textColor = Colors.black87;
  String text = order.paymentStatus.toUpperCase();

  if (order.paymentMode.toUpperCase() == 'COD') {
    text = 'PAY ON DELIVERY';
    bgColor = Colors.blue.shade100;
    textColor = Colors.blue.shade800;
  } else {
    switch (order.paymentStatus.toUpperCase()) {
      case 'PAID':
      case 'COMPLETED':
      case 'SUCCESS':
        text = 'PAID';
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'PENDING':
      case 'INITIATED':
        text = 'PAYMENT PENDING';
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'FAILED':
        text = 'FAILED';
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        bgColor = Colors.grey.shade300;
        textColor = Colors.grey.shade800;
    }
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
        fontSize: 11,
      ),
    ),
  );
}

Widget _buildItemReturnStatusBadge(String status) {
  Color bgColor;
  Color textColor;
  String label;

  switch (status.toLowerCase()) {
    case 'return_requested':
    case 'replacement_approval':
    case 'refund_approval':
      bgColor = Colors.amber.shade50;
      textColor = Colors.amber.shade900;
      label = 'Return Requested';
      break;
    case 'return_initiated':
    case 'return_picked':
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade900;
      label = 'Return In Progress';
      break;
    case 'returned':
    case 'refund_completed':
    case 'replacement_complete':
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade900;
      label = status.toLowerCase() == 'refund_completed'
          ? 'Refund Completed'
          : 'Returned';
      break;
    case 'returnrejected':
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade900;
      label = 'Return Rejected';
      break;
    default:
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade800;
      label = status.toUpperCase().replaceAll('_', ' ');
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: textColor.withAlpha(50),
      ), // Using withAlpha for modern Flutter
    ),
    child: Text(
      label,
      style: AppTextStyles.label.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );
}

String _getEffectiveStatus(OrderDetailEntity order) {
  // 1. Check if any item has a return status
  final returnItems = order.items
      .where(
        (item) => item.returnStatus != null && item.returnStatus!.isNotEmpty,
      )
      .toList();

  if (returnItems.isNotEmpty) {
    // Return the most "advanced" return status among items
    // Priority: returned/refunded > transition states > requested
    String bestStatus = returnItems.first.returnStatus!;
    int maxPriority = _getSubStatusPriority(bestStatus);

    for (final item in returnItems) {
      int priority = _getSubStatusPriority(item.returnStatus!);
      if (priority > maxPriority) {
        maxPriority = priority;
        bestStatus = item.returnStatus!;
      }
    }
    return bestStatus;
  }

  // 2. Fallback to top-level order status
  return order.orderStatus;
}

int _getSubStatusPriority(String status) {
  switch (status.toLowerCase()) {
    case 'returned':
    case 'refund_completed':
    case 'replacement_complete':
      return 10;
    case 'return_in_transit':
      return 8;
    case 'return_picked':
      return 6;
    case 'return_initiated':
      return 4;
    case 'return_requested':
      return 2;
    default:
      return 0;
  }
}
