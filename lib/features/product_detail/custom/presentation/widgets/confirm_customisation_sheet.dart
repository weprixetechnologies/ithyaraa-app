import 'package:flutter/material.dart';
import 'package:ithyaraaapp/core/theme/app_text_styles.dart';
import '../../domain/entities/custom_input.dart';
import '../../domain/entities/dress_type.dart';

/// Confirmation bottom sheet matching the website's ConfirmDrawer.
/// Shown before Add to Cart or Buy Now so the user can review their customisations.
class ConfirmCustomisationSheet extends StatelessWidget {
  final String productName;
  final String? productImage;
  final int quantity;
  final DressTypeEntity? selectedDressType;
  final List<CustomInputEntity> customInputs;
  final Map<String, dynamic> customInputValues;
  final bool isBuyNow;
  final VoidCallback onConfirm;

  const ConfirmCustomisationSheet({
    super.key,
    required this.productName,
    this.productImage,
    required this.quantity,
    this.selectedDressType,
    required this.customInputs,
    required this.customInputValues,
    this.isBuyNow = false,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String productName,
    String? productImage,
    required int quantity,
    DressTypeEntity? selectedDressType,
    required List<CustomInputEntity> customInputs,
    required Map<String, dynamic> customInputValues,
    bool isBuyNow = false,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmCustomisationSheet(
        productName: productName,
        productImage: productImage,
        quantity: quantity,
        selectedDressType: selectedDressType,
        customInputs: customInputs,
        customInputValues: customInputValues,
        isBuyNow: isBuyNow,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Almost there',
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBuyNow ? 'Review Your Order' : 'Confirm Customisation',
                        style: AppTextStyles.headingMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Product row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (productImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      productImage!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                if (productImage != null) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: $quantity',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      if (selectedDressType != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${selectedDressType!.label} · ₹${selectedDressType!.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.amber.shade800, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom inputs summary
          if (customInputs.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Customisations',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...customInputs.map((input) {
                    final value = customInputValues[input.id];
                    final displayValue = (value != null && value.toString().trim().isNotEmpty)
                        ? value.toString()
                        : 'Not provided';
                    final isEmpty = value == null || value.toString().trim().isEmpty;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              input.label,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              displayValue,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
                                color: isEmpty ? Colors.grey.shade400 : Colors.grey.shade900,
                                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const Divider(height: 1),

          // Footer buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('← Edit', style: TextStyle(color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      isBuyNow ? 'Proceed to Checkout →' : 'Confirm & Add to Cart →',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
