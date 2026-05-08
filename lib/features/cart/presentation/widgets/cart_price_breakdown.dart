import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';
import '../../../checkout/presentation/providers/checkout_provider.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'stock_validation_bottom_sheet.dart';

/// Cart price breakdown widget
class CartPriceBreakdown extends ConsumerWidget {
  const CartPriceBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only summary
    final summary = ref.watch(
      cartControllerProvider.select((state) => state.cartState?.summary),
    );

    if (summary == null) {
      return const SizedBox.shrink();
    }

    // Check if there are selected items
    final cartPageState = ref.watch(cartControllerProvider);
    final hasChanges = cartPageState.hasChanges;
    final isUpdating = cartPageState.isUpdatingSelection;
    final localSelected = cartPageState.localSelectedItems ?? {};
    
    // Check if any items from the LOCAL selection are unavailable
    final hasSelectedItems = localSelected.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PriceRow(label: 'Subtotal', value: summary.subtotal),
              if (summary.totalDiscount > 0)
                _PriceRow(
                  label: 'Discount',
                  value: -summary.totalDiscount,
                  isDiscount: true,
                ),
              if (summary.shipping > 0)
                _PriceRow(label: 'Shipping', value: summary.shipping),

              // Watch checkout state for applied coupon
              Consumer(
                builder: (context, ref, child) {
                  final checkoutState = ref.watch(checkoutProvider);
                  final isCouponApplied =
                      checkoutState.couponCode != null &&
                      checkoutState.couponResponse != null &&
                      checkoutState.couponResponse!['success'] == true;

                  if (!isCouponApplied) return const SizedBox.shrink();

                  double couponDiscount = 0;
                  final rawDiscount = checkoutState.couponResponse!['discount'];
                  if (rawDiscount is num) {
                    couponDiscount = rawDiscount.toDouble();
                  } else if (rawDiscount is String) {
                    couponDiscount = double.tryParse(rawDiscount) ?? 0;
                  }

                  return Column(
                    children: [
                      _PriceRow(
                        label: 'Coupon Discount (${checkoutState.couponCode})',
                        value: -couponDiscount,
                        isDiscount: true,
                      ),
                    ],
                  );
                },
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '₹${_calculateFinalTotal(summary, ref).toStringAsFixed(0)}',
                    style: AppTextStyles.price.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (hasSelectedItems)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isUpdating 
                        ? null 
                        : () {
                            final controller = ref.read(cartControllerProvider.notifier);
                            
                            if (hasChanges) {
                              // If changes exist, update the cart first
                              controller.applySelectionUpdate();
                            } else {
                              // Standard checkout flow
                              final cartState = cartPageState.cartState;
                              final unavailableItems = cartState?.items
                                  .where((item) => item.isSelected && !item.isAvailable)
                                  .toList() ?? [];

                              if (unavailableItems.isNotEmpty) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => StockValidationBottomSheet(
                                    items: unavailableItems,
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CheckoutPage(),
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasChanges ? const Color(0xFFFFD232) : Colors.black,
                      foregroundColor: hasChanges ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                hasChanges ? 'Update Cart Selection' : 'Proceed to Checkout',
                                style: AppTextStyles.button.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: hasChanges ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                hasChanges ? Icons.sync_rounded : Icons.arrow_forward_rounded, 
                                size: 20,
                                color: hasChanges ? Colors.black : Colors.white,
                              ),
                            ],
                          ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Select items to continue',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateFinalTotal(dynamic summary, WidgetRef ref) {
    final checkoutState = ref.read(checkoutProvider);
    double total = summary.total;

    if (checkoutState.couponCode != null &&
        checkoutState.couponResponse != null &&
        checkoutState.couponResponse!['success'] == true) {
      double couponDiscount = 0;
      final rawDiscount = checkoutState.couponResponse!['discount'];
      if (rawDiscount is num) {
        couponDiscount = rawDiscount.toDouble();
      } else if (rawDiscount is String) {
        couponDiscount = double.tryParse(rawDiscount) ?? 0;
      }

      total -= couponDiscount;
    }

    return total > 0 ? total : 0;
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${value < 0 ? '-' : ''}₹${value.abs().toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isDiscount ? const Color(0xFF10B981) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
