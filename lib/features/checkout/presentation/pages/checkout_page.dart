import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../address/presentation/widgets/address_selection_widget.dart';
import '../providers/checkout_provider.dart';
import '../state/checkout_state.dart';

/// Checkout Page
///
/// Displays:
/// - Selected cart items (read-only)
/// - Cart summary (subtotal, discount, total)
/// - Address selection
/// - Payment mode selection (COD / PREPAID)
/// - Coupon input & apply
/// - Wallet balance input (optional)
/// - Place Order button
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _walletController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final cartState = ref.watch(
      cartControllerProvider.select((state) => state.cartState),
    );

    // Get selected items
    final selectedItems =
        cartState?.items.where((item) => item.isSelected).toList() ?? [];

    // Pre-fill coupon controller if coupon is already applied
    if (checkoutState.couponCode != null && _couponController.text.isEmpty) {
      _couponController.text = checkoutState.couponCode!;
    }

    if (cartState == null || selectedItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No items selected for checkout',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'CHECKOUT',
          style: AppTextStyles.headingSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Cart Items Section
            _buildCartItemsSection(selectedItems),

            // Coupon Section
            _buildCouponSection(checkoutState),

            // Address Selection Section
            _buildAddressSection(checkoutState),

            // Payment Mode Selection
            _buildPaymentModeSection(checkoutState),

            // Wallet Section
            _buildWalletSection(checkoutState),

            // Price Breakdown Section
            _buildCartSummarySection(cartState.summary, checkoutState),

            // Error Display
            if (checkoutState.error != null)
              _buildErrorSection(checkoutState.error!),

            const SizedBox(height: 140), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(cartState.summary, checkoutState),
    );
  }

  Widget _buildCartItemsSection(List<CartItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                'ORDER ITEMS (${items.length})',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildCartItemRow(item),
                if (index < items.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Colors.grey.shade100),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(CartItem item) {
    final imageUrl = item.imageUrl;
    final itemTotal = item.lineTotalAfter ?? (item.unitPriceAfter ?? 0) * item.quantity;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
        ),
        const SizedBox(width: 12),
        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.variationName != null && item.variationName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.variationName!.replaceAll('_', ' '),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Price and Quantity
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${itemTotal.toStringAsFixed(0)}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Qty: ${item.quantity}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  Widget _buildCartSummarySection(cartSummary, CheckoutState checkoutState) {
    // Get coupon discount if applied
    double couponDiscount = 0;
    if (checkoutState.couponResponse != null &&
        checkoutState.couponResponse!['success'] == true) {
      final rawDiscount = checkoutState.couponResponse!['discount'];
      if (rawDiscount is num) {
        couponDiscount = rawDiscount.toDouble();
      } else if (rawDiscount is String) {
        couponDiscount = double.tryParse(rawDiscount) ?? 0;
      }
    }

    final isCOD = checkoutState.paymentMode == 'COD';
    final double handlingFee = isCOD ? 8 : 0;

    // Calculate final total
    double finalTotal = (cartSummary.total ?? 0).toDouble() -
        couponDiscount -
        checkoutState.walletApplied +
        handlingFee;

    if (finalTotal < 0) finalTotal = 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YOUR CART BREAKDOWN',
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildPriceRow('Base Price', cartSummary.subtotal),
          if (cartSummary.totalDiscount > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              'Discount Applied',
              -cartSummary.totalDiscount,
              isDiscount: true,
            ),
          ],
          if (couponDiscount > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              'Coupon Discount',
              -couponDiscount,
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 12),
          _buildPriceRow(
            'Shipping Charges',
            cartSummary.shipping,
            isFree: cartSummary.shipping <= 0,
          ),
          if (isCOD) ...[
            const SizedBox(height: 12),
            _buildPriceRow('Handling Fee (COD)', handlingFee),
          ],
          if (checkoutState.walletApplied > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              'Wallet Applied',
              -checkoutState.walletApplied,
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Total ',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '(incl. taxes)',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${finalTotal.toStringAsFixed(0)}',
                style: AppTextStyles.price.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          
          // Coins Notice
          if (finalTotal >= 100) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will earn ${ (finalTotal / 100).floor() } Ithyaraa coins on this order.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isDiscount = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDiscount ? const Color(0xFF16A34A) : const Color(0xFF4B5563),
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        Text(
          isFree ? 'Free' : '${isDiscount ? "-₹" : "₹"}${value.abs().toStringAsFixed(0)}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: (isDiscount || isFree) ? const Color(0xFF16A34A) : Colors.black,
            fontWeight: (isDiscount || isFree || label.contains('Shipping')) ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentModeSection(CheckoutState checkoutState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUGGESTED FOR YOU',
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // COD Option
          _buildPaymentCard(
            title: 'Cash on Delivery',
            subtitle: 'Nominal handling fee applicable: ₹8',
            value: 'COD',
            selectedValue: checkoutState.paymentMode,
            onChanged: (val) => ref.read(checkoutProvider.notifier).setPaymentMode(val),
          ),
          
          const SizedBox(height: 12),
          
          // Online Payment Option
          _buildPaymentCard(
            title: 'Online Payment',
            subtitle: 'Pay securely via UPI, Cards & Wallets using PhonePe',
            value: 'PREPAID',
            selectedValue: checkoutState.paymentMode,
            onChanged: (val) => ref.read(checkoutProvider.notifier).setPaymentMode(val),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'PhonePe',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5F259F), // PhonePe Purple
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required String value,
    required String selectedValue,
    required ValueChanged<String> onChanged,
    Widget? trailing,
  }) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD232) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD232) : Colors.grey.shade300,
                  width: isSelected ? 5 : 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(CheckoutState checkoutState) {
    final isCouponApplied = checkoutState.couponCode != null &&
        checkoutState.couponResponse != null &&
        checkoutState.couponResponse!['success'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                'OFFERS & COUPONS',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isCouponApplied) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coupon Applied!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xFF166534),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'You saved with "${checkoutState.couponCode}"',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF166534),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(checkoutProvider.notifier).removeCoupon();
                      _couponController.clear();
                    },
                    child: Text(
                      'Remove',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      enabled: !checkoutState.loading,
                    ),
                  ),
                  GestureDetector(
                    onTap: checkoutState.loading || _couponController.text.isEmpty
                        ? null
                        : () {
                            final cartState = ref.read(cartControllerProvider).cartState;
                            ref.read(checkoutProvider.notifier).applyCoupon(
                                  _couponController.text,
                                  cartID: cartState?.cartID != null
                                      ? int.tryParse(cartState!.cartID!)
                                      : null,
                                );
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _couponController.text.isEmpty ? Colors.grey.shade300 : const Color(0xFFFFD232),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Apply',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressSection(CheckoutState checkoutState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: AddressSelectionWidget(
        selectedAddressID: checkoutState.selectedAddressID,
        onAddressSelected: (addressID) {
          ref.read(checkoutProvider.notifier).setAddress(addressID);
        },
      ),
    );
  }

  Widget _buildWalletSection(CheckoutState checkoutState) {
    // Pre-fill if wallet is already applied
    if (checkoutState.walletApplied > 0 && _walletController.text.isEmpty) {
      _walletController.text = checkoutState.walletApplied.toStringAsFixed(2);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                'WALLET BALANCE',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _walletController,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter amount (optional)',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.currency_rupee, size: 14, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !checkoutState.loading,
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0;
                ref.read(checkoutProvider.notifier).setWalletApplied(amount);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(cartSummary, CheckoutState checkoutState) {
    // Re-calculate total for button
    double couponDiscount = 0;
    if (checkoutState.couponResponse != null && checkoutState.couponResponse!['success'] == true) {
      final rawDiscount = checkoutState.couponResponse!['discount'];
      couponDiscount = (rawDiscount is num) ? rawDiscount.toDouble() : (double.tryParse(rawDiscount.toString()) ?? 0);
    }
    
    final isCOD = checkoutState.paymentMode == 'COD';
    final double handlingFee = isCOD ? 8 : 0;
    double finalTotal = (cartSummary.total ?? 0).toDouble() - couponDiscount - checkoutState.walletApplied + handlingFee;
    if (finalTotal < 0) finalTotal = 0;

    final canPlaceOrder = checkoutState.selectedAddressID != null && checkoutState.selectedAddressID!.isNotEmpty && !checkoutState.loading;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYABLE AMOUNT',
                  style: AppTextStyles.label.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                ),
                Text(
                  '₹${finalTotal.toStringAsFixed(0)}',
                  style: AppTextStyles.price.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: canPlaceOrder ? () => ref.read(checkoutProvider.notifier).placeOrder(context) : null,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: canPlaceOrder ? const Color(0xFFFFD232) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: canPlaceOrder ? [
                    BoxShadow(
                      color: const Color(0xFFFFD232).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ] : [],
                ),
                child: Center(
                  child: checkoutState.loading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.enhanced_encryption_outlined, size: 18, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(
                              'Place Order Now',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF991B1B), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
