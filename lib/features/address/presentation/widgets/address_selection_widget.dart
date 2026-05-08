import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/address.dart';
import '../providers/address_providers.dart';
import 'add_address_dialog.dart';

/// Address selection widget
///
/// Displays list of addresses with radio selection
/// Has "Add New Address" button
/// Calls onAddressSelected callback when address is selected
class AddressSelectionWidget extends ConsumerStatefulWidget {
  final String? selectedAddressID;
  final Function(String addressID) onAddressSelected;

  const AddressSelectionWidget({
    super.key,
    this.selectedAddressID,
    required this.onAddressSelected,
  });

  @override
  ConsumerState<AddressSelectionWidget> createState() =>
      _AddressSelectionWidgetState();
}

class _AddressSelectionWidgetState
    extends ConsumerState<AddressSelectionWidget> {
  @override
  void initState() {
    super.initState();
    // Load addresses if not already hydrated
    // The loadAddresses method will check hydration flag internally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressControllerProvider.notifier).loadAddresses();
    });
  }

  Future<void> _showAddAddressDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddAddressDialog(),
    );

    if (result == true) {
      // Address will be automatically refreshed by the controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  'DELIVERY ADDRESS',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (addressState.addresses.isNotEmpty)
              TextButton.icon(
                onPressed: _showAddAddressDialog,
                icon: const Icon(Icons.add, size: 14, color: Color(0xFF2563EB)),
                label: Text(
                  'Add New',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (addressState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (addressState.error != null)
          _buildErrorState(addressState.error!)
        else if (addressState.addresses.isEmpty)
          _buildEmptyState()
        else
          _buildAddressList(addressState.addresses),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF991B1B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(addressControllerProvider.notifier).loadAddresses(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No addresses found',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddAddressDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Delivery Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD232),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(List<Address> addresses) {
    return Column(
      children: addresses.map((address) {
        final isSelected = widget.selectedAddressID == address.addressID;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => widget.onAddressSelected(address.addressID),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD232) : const Color(0xFFE5E7EB),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
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
                        Row(
                          children: [
                            Text(
                              address.type.toUpperCase(),
                              style: AppTextStyles.label.copyWith(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.fullAddress,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        if (address.phonenumber.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 12, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(
                                address.phonenumber,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
