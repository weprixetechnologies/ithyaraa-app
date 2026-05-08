import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/repositories/presale_repository.dart';
import '../state/prebooking_state.dart';
import '../providers/presale_providers.dart';
import '../../../address/presentation/providers/address_providers.dart';

class PrebookingController extends StateNotifier<PrebookingState> {
  final PresaleRepository repository;
  final Ref ref;

  PrebookingController(this.repository, this.ref) : super(const PrebookingState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Automatically select the first address if available
    final addressState = ref.read(addressControllerProvider);
    if (addressState.addresses.isNotEmpty) {
      state = state.copyWith(selectedAddressID: addressState.addresses.first.addressID);
    }
  }

  void selectAddress(String addressID) {
    state = state.copyWith(selectedAddressID: addressID);
  }

  void setPaymentMode(String mode) {
    state = state.copyWith(paymentMode: mode);
  }

  Future<void> placePrebookingOrder({
    required String productID,
    String? variationID,
    int quantity = 1,
  }) async {
    if (state.selectedAddressID == null) {
      state = state.copyWith(error: 'Please select a delivery address');
      return;
    }

    state = state.copyWith(isPlacingOrder: true, error: null);

    try {
      final response = await repository.placePrebookingOrder(
        addressID: state.selectedAddressID!,
        productID: productID,
        variationID: variationID,
        paymentMode: state.paymentMode,
        quantity: quantity,
      );

      if (response['success'] == true) {
        final preBookingID = response['preBookingID']?.toString();
        
        // Handle COD
        if (state.paymentMode == 'COD') {
          state = state.copyWith(isPlacingOrder: false, successPreBookingID: preBookingID);
          return;
        }

        // Handle Prepaid (PhonePe)
        final flow = response['flow'] as String?;
        if (flow == 'TOKEN') {
          final payUrl = response['payUrl'] as String?;
          if (payUrl != null && payUrl.isNotEmpty) {
            final uri = Uri.tryParse(payUrl.trim());
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              state = state.copyWith(isPlacingOrder: false, successPreBookingID: preBookingID);
              return;
            }
          }
        } else {
          // Standard redirect flow
          final rawUrl = (response['checkoutPageUrl'] ?? response['url']) as String?;
          if (rawUrl != null && rawUrl.isNotEmpty) {
            final uri = Uri.tryParse(rawUrl.trim());
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              state = state.copyWith(isPlacingOrder: false, successPreBookingID: preBookingID);
              return;
            }
          }
        }
        
        state = state.copyWith(isPlacingOrder: false, successPreBookingID: preBookingID);
      } else {
        state = state.copyWith(
          isPlacingOrder: false,
          error: response['message'] ?? 'Failed to place prebooking order',
        );
      }
    } catch (e) {
      state = state.copyWith(isPlacingOrder: false, error: e.toString());
    }
  }
}

final prebookingControllerProvider = StateNotifierProvider<PrebookingController, PrebookingState>((ref) {
  final repository = ref.watch(presaleRepositoryProvider);
  return PrebookingController(repository, ref);
});
