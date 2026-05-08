import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/prebooking_controller.dart';
import '../../domain/entities/presale_product_detail.dart';
import '../../../product_detail/variable/domain/entities/variation.dart';
import '../../../address/presentation/widgets/address_selection_widget.dart';
import '../../../../core/theme/app_text_styles.dart';

class PresaleBuyNowBottomSheet extends ConsumerWidget {
  final PresaleProductDetailEntity product;
  final VariationEntity? variation;
  final int quantity;

  const PresaleBuyNowBottomSheet({
    super.key,
    required this.product,
    this.variation,
    this.quantity = 1,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prebookingControllerProvider);
    final controller = ref.read(prebookingControllerProvider.notifier);

    // If successfully placed order, show success and close
    if (state.successPreBookingID != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pre-booking successful! ID: ${state.successPreBookingID}'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Complete Your Prebooking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(),
            
            // Product Summary
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(product.featuredImages.first.imgUrl, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (variation != null)
                          Text(
                            variation!.attributes.map((a) => a.attributeValue).join(' / '),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        Text('Quantity: $quantity', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            // Address Selection
            AddressSelectionWidget(
              selectedAddressID: state.selectedAddressID,
              onAddressSelected: controller.selectAddress,
            ),
            
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            // Payment Modes
            _buildPaymentOption(
              context: context,
              title: 'Cash on Delivery',
              subtitle: 'Pay when you receive the product',
              icon: Icons.money,
              value: 'COD',
              groupValue: state.paymentMode,
              onChanged: (val) => controller.setPaymentMode(val!),
            ),
            _buildPaymentOption(
              context: context,
              title: 'Online Payment',
              subtitle: 'Pay securely using PhonePe',
              icon: Icons.payment,
              value: 'PREPAID',
              groupValue: state.paymentMode,
              onChanged: (val) => controller.setPaymentMode(val!),
            ),
            
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(state.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
              
            const SizedBox(height: 16),
            // Place Order Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isPlacingOrder
                      ? null
                      : () => controller.placePrebookingOrder(
                            productID: product.productID,
                            variationID: variation?.variationID,
                            quantity: quantity,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isPlacingOrder
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CONFIRM PRE-BOOKING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey.shade800)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: Colors.black,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
