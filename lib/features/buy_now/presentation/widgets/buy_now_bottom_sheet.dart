import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithyaraaapp/core/theme/app_text_styles.dart';
import 'package:ithyaraaapp/features/buy_now/presentation/state/buy_now_state.dart';
import 'package:ithyaraaapp/features/buy_now/presentation/providers/buy_now_provider.dart';
import 'package:ithyaraaapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:ithyaraaapp/features/address/domain/entities/address.dart';
import 'package:ithyaraaapp/features/address/presentation/providers/address_providers.dart';
import 'package:ithyaraaapp/features/address/presentation/widgets/add_address_dialog.dart';

class BuyNowBottomSheet extends ConsumerStatefulWidget {
  final BuyNowState initialState;

  const BuyNowBottomSheet({super.key, required this.initialState});

  static Future<void> show(BuildContext context, BuyNowState state) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuyNowBottomSheet(initialState: state),
    );
  }

  @override
  ConsumerState<BuyNowBottomSheet> createState() => _BuyNowBottomSheetState();
}

class _BuyNowBottomSheetState extends ConsumerState<BuyNowBottomSheet> {
  // Design System Colors
  static const Color primaryColor = Color(0xFF111827);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color textLight = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buyNowProvider(widget.initialState));
    final controller = ref.read(buyNowProvider(widget.initialState).notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: state.step == BuyNowStep.details
                    ? Stack(
                        children: [
                          ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                            children: [
                              _ProductHeader(
                                state: state,
                                controller: controller,
                              ),
                              const SizedBox(height: 24),
                              _AddressSection(
                                state: state,
                                controller: controller,
                                isLoggedIn: ref.watch(authProvider).isLoggedIn,
                              ),
                              const SizedBox(height: 24),
                              _CouponSection(
                                state: state,
                                controller: controller,
                              ),
                              const SizedBox(height: 24),
                              _PaymentSection(
                                state: state,
                                controller: controller,
                              ),
                              const SizedBox(height: 24),
                              _PriceSummary(state: state),
                            ],
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _buildConfirmButton(
                              context,
                              state,
                              controller,
                            ),
                          ),
                        ],
                      )
                    : _buildOtpStep(context, state, controller),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(
    BuildContext context,
    BuyNowState state,
    dynamic controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user_outlined, size: 64, color: accentBlue),
          const SizedBox(height: 16),
          Text(
            'Verify your phone',
            style: AppTextStyles.headingMedium.copyWith(color: primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            'We have sent a 6-digit verification code to',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: textLight),
          ),
          Text(
            state.guestPhone,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            onChanged: (val) => controller.updateOtpCode(val),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: AppTextStyles.otpInput,
            decoration: InputDecoration(
              hintText: '000000',
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: accentBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ErrorBar(message: state.error!),
            ),
          _AnimatedButton(
            onTap: (state.isPlacingOrder || state.isVerifyingOtp)
                ? null
                : () => controller.verifyOtpAndPlaceOrder(context),
            isLoading: state.isPlacingOrder || state.isVerifyingOtp,
            text: 'Verify & Confirm Order',
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: state.isLoading ? null : () => controller.resendOtp(),
            child: Text(
              state.isLoading ? 'Sending...' : 'Resend OTP',
              style: const TextStyle(
                color: accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => controller.backToDetails(),
            child: const Text(
              'Change Phone Number',
              style: TextStyle(color: textLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    BuyNowState state,
    dynamic controller,
  ) {
    bool isLoading = state.isPlacingOrder || state.isCheckingPhone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ErrorBar(message: state.error!),
              ),
            _AnimatedButton(
              onTap: isLoading
                  ? null
                  : () => controller.handleOrderAction(context),
              isLoading: isLoading,
              text: state.paymentMode == 'COD'
                  ? 'Confirm Order →'
                  : 'Pay ₹${state.grandTotal.toInt()} →',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String text;

  const _AnimatedButton({
    this.onTap,
    this.isLoading = false,
    required this.text,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.onTap == null
                ? Colors.grey.shade300
                : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.text,
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final BuyNowState state;
  final dynamic controller;

  const _ProductHeader({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: state.productImage != null
                ? Image.network(
                    state.productImage!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : Container(width: 64, height: 64, color: Colors.grey.shade200),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.productName ?? 'Product Name',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${state.salePrice.toInt()}',
                      style: AppTextStyles.price.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    if (state.regularPrice > state.salePrice) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${state.regularPrice.toInt()}',
                        style: AppTextStyles.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: const Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Save ₹${(state.regularPrice - state.salePrice).toInt()}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF16A34A),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _QuantityStepper(
            quantity: state.quantity,
            onChanged: (val) => controller.updateQuantity(val),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(
            Icons.remove,
            quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _stepperButton(Icons.add, () => onChanged(quantity + 1)),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.grey : const Color(0xFF111827),
        ),
      ),
    );
  }
}

class _AddressSection extends ConsumerWidget {
  final BuyNowState state;
  final dynamic controller;
  final bool isLoggedIn;

  const _AddressSection({
    required this.state,
    required this.controller,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CHOOSE DELIVERY ADDRESS',
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (isLoggedIn)
              TextButton(
                onPressed: () {
                  // Navigate to full address list or edit
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Color(0xFF2563EB), fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoggedIn)
          _buildAuthAddresses(context, ref)
        else
          _GuestAddressForm(state: state, controller: controller),
      ],
    );
  }

  Widget _buildAuthAddresses(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressControllerProvider);

    if (addressState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        ...addressState.addresses.map(
          (addr) => _AddressCard(
            address: addr,
            isSelected: state.selectedAddressID == addr.addressID,
            onTap: () => controller.setAddress(addr.addressID),
          ),
        ),
        const SizedBox(height: 10),
        _AddAddressButton(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => const AddAddressDialog(),
            );
          },
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              address.type.toLowerCase() == 'home'
                  ? Icons.home_outlined
                  : Icons.work_outline,
              color: const Color(0xFF2563EB),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.type.toUpperCase(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${address.line1}${address.line2.isNotEmpty ? ', ${address.line2}' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF4B5563),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address.landmark.isNotEmpty)
                    Text(
                      'Near ${address.landmark}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAddressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            style: BorderStyle.solid,
          ), // Dash effect not standard in BoxDecor, but can use custom painter or just grey border
        ),
        child: const Row(
          children: [
            Icon(Icons.add, size: 18, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text(
              'Add New Address',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestAddressForm extends StatelessWidget {
  final BuyNowState state;
  final dynamic controller;

  const _GuestAddressForm({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          'Full Name',
          (val) => controller.updateGuestInfo(name: val),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          'Email Address',
          (val) => controller.updateGuestInfo(email: val),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          'Phone Number',
          (val) => controller.updateGuestInfo(phone: val),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        _buildTextField('Address Line 1', (val) => _updateAddress(line1: val)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'City',
                (val) => _updateAddress(city: val),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                'Pincode',
                (val) => _updateAddress(pincode: val),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField('State', (val) => _updateAddress(state: val)),
      ],
    );
  }

  void _updateAddress({
    String? line1,
    String? city,
    String? pincode,
    String? state,
  }) {
    final current = this.state.newAddressData ?? {};
    final updated = {
      ...current,
      if (line1 != null) 'line1': line1,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
      if (state != null) 'state': state,
      'type': 'home',
    };
    controller.updateNewAddressData(updated);
  }

  Widget _buildTextField(
    String label,
    ValueChanged<String> onChanged, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}

class _CouponSection extends StatefulWidget {
  final BuyNowState state;
  final dynamic controller;

  const _CouponSection({required this.state, required this.controller});

  @override
  State<_CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<_CouponSection> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isApplied = widget.state.couponCode.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPLY COUPON',
            style: AppTextStyles.label.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_num_outlined,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: !isApplied,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: isApplied ? widget.state.couponCode : 'SAVE10',
                      border: InputBorder.none,
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: isApplied
                      ? () {
                          widget.controller.removeCoupon();
                          _textController.clear();
                        }
                      : () =>
                            widget.controller.applyCoupon(_textController.text),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isApplied ? 'Remove' : 'Apply',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isApplied)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF16A34A),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Coupon applied: -₹${widget.state.couponDiscount.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            '🔥 Available Offers',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          _OfferItem(title: 'SAVE10', subtitle: 'Save ₹10 on this order'),
          _OfferItem(
            title: 'FREESHIP',
            subtitle: 'Free shipping on all orders',
          ),
        ],
      ),
    );
  }
}

class _OfferItem extends StatelessWidget {
  final String title;
  final String subtitle;
  const _OfferItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$title → ',
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  final BuyNowState state;
  final dynamic controller;

  const _PaymentSection({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT METHOD',
          style: AppTextStyles.label.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _PaymentOption(
                title: 'UPI / Card / NetBanking',
                subtitle: 'Fast & secure',
                value: 'PREPAID',
                isSelected: state.paymentMode == 'PREPAID',
                price: state.grandTotal > 0
                    ? '₹${state.grandTotal.toInt()}'
                    : '',
                onTap: () => controller.setPaymentMode('PREPAID'),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              _PaymentOption(
                title: 'Cash on Delivery',
                subtitle: 'Additional fee may apply',
                value: 'COD',
                isSelected: state.paymentMode == 'COD',
                price: '+₹8 fee',
                onTap: () => controller.setPaymentMode('COD'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final bool isSelected;
  final String price;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isSelected,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: Color(0xFF22C55E), width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFD1D5DB),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final BuyNowState state;

  const _PriceSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Product Total', '₹${state.subtotal.toInt()}'),
        if (state.offerSavedAmount > 0)
          _row(
            'Offer Discount',
            '-₹${state.offerSavedAmount.toInt()}',
            isDiscount: true,
          ),
        if (state.couponDiscount > 0)
          _row(
            'Coupon Discount',
            '-₹${state.couponDiscount.toInt()}',
            isDiscount: true,
          ),
        _row(
          'Shipping',
          state.shippingFee == 0 ? 'FREE' : '₹${state.shippingFee.toInt()}',
        ),
        if (state.paymentMode == 'COD') _row('COD Fee', '₹8.00'),
        const Divider(height: 24, color: Color(0xFFE5E7EB)),
        _row('Total', '₹${state.grandTotal.toInt()}', isTotal: true),
      ],
    );
  }

  Widget _row(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? const Color(0xFF111827)
                  : const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBar extends StatelessWidget {
  final String message;
  const _ErrorBar({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
