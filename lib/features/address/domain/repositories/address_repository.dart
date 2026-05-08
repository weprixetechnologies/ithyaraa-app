import '../../domain/entities/address.dart';

/// Repository interface for address operations
abstract class AddressRepository {
  /// Get all addresses for authenticated user
  Future<List<Address>> getAllAddresses();

  /// Add a new address
  Future<void> addAddress(Map<String, dynamic> body);
}
