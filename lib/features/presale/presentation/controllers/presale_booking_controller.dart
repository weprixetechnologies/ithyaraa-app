import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/presale_booking.dart';
import '../../domain/repositories/presale_repository.dart';
import '../providers/presale_providers.dart';

class PresaleBookingState {
  final List<PresaleBookingEntity> bookings;
  final bool isLoading;
  final String? error;
  final PresaleBookingEntity? selectedBooking;

  PresaleBookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
    this.selectedBooking,
  });

  PresaleBookingState copyWith({
    List<PresaleBookingEntity>? bookings,
    bool? isLoading,
    String? error,
    PresaleBookingEntity? selectedBooking,
  }) {
    return PresaleBookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedBooking: selectedBooking ?? this.selectedBooking,
    );
  }
}

class PresaleBookingController extends StateNotifier<PresaleBookingState> {
  final PresaleRepository _repository;

  PresaleBookingController(this._repository) : super(PresaleBookingState()) {
    loadUserBookings();
  }

  Future<void> loadUserBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookings = await _repository.getUserPresaleBookings();
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadBookingDetails(String preBookingID) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final booking = await _repository.getPresaleBookingDetails(preBookingID);
      state = state.copyWith(selectedBooking: booking, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final presaleBookingControllerProvider =
    StateNotifierProvider.autoDispose<PresaleBookingController, PresaleBookingState>((ref) {
  final repository = ref.watch(presaleRepositoryProvider);
  return PresaleBookingController(repository);
});
