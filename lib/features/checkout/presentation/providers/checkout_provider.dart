import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../order/presentation/providers/order_providers.dart';
import '../controllers/checkout_notifier.dart';
import '../state/checkout_state.dart';

/// Provider for checkout notifier
final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(
    placeOrderUseCase: ref.read(placeOrderUseCaseProvider),
    applyCouponUseCase: ref.read(applyCouponUseCaseProvider),
    ref: ref,
  ),
);
