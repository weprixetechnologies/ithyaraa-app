import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shipping address widget - displays shipping address and contact information
class ShippingAddressWidget extends StatelessWidget {
  final String shippingAddress;
  final String? email;
  final String? contactNumber;

  const ShippingAddressWidget({
    super.key,
    required this.shippingAddress,
    this.email,
    this.contactNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.blue.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delivery Address',
                  style: AppTextStyles.headingSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Email (first)
            if (email != null && email!.isNotEmpty) ...[
              Text(
                email!,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
            
            // Shipping Address
            Text(
              shippingAddress,
              style: AppTextStyles.bodyMedium,
            ),
            
            // Contact Number
            if (contactNumber != null && contactNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: Colors.blue.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contactNumber!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
