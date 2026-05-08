import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/address.dart';
import '../../domain/usecases/get_all_addresses_usecase.dart';
import '../../domain/usecases/add_address_usecase.dart';
import '../state/address_state.dart';

/// Address controller managing address list state
class AddressController extends StateNotifier<AddressState> {
  final GetAllAddressesUseCase getAllAddressesUseCase;
  final AddAddressUseCase addAddressUseCase;
  bool _hasHydrated = false;

  AddressController({
    required this.getAllAddressesUseCase,
    required this.addAddressUseCase,
  }) : super(const AddressState());

  /// Load all addresses
  /// Only loads if not already hydrated
  Future<void> loadAddresses() async {
    // Skip if already hydrated
    if (_hasHydrated) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final addresses = await getAllAddressesUseCase();
      _hasHydrated = true; // Mark as hydrated after successful load
      state = state.copyWith(
        addresses: addresses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      // Don't set _hasHydrated to true on error, so it can retry
    }
  }

  /// Refresh addresses
  /// Forces reload regardless of hydration state
  Future<void> refresh() async {
    _hasHydrated = false; // Reset hydration to force reload
    await loadAddresses();
  }

  /// Add a new address and refresh the list
  Future<void> addAddress(Map<String, dynamic> body) async {
    try {
      await addAddressUseCase(body);
      // Reset hydration flag so addresses are reloaded after adding
      _hasHydrated = false;
      // Refresh the list after adding
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow; // Re-throw so the UI can show error
    }
  }

  /// Get address by ID
  Address? getAddressById(String addressID) {
    try {
      return state.addresses.firstWhere(
        (address) => address.addressID == addressID,
      );
    } catch (e) {
      return null;
    }
  }
}
