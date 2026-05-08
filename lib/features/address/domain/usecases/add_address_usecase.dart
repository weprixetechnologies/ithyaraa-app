import '../repositories/address_repository.dart';

/// Use case for adding a new address
class AddAddressUseCase {
  final AddressRepository repository;

  AddAddressUseCase(this.repository);

  Future<void> call(Map<String, dynamic> body) async {
    return await repository.addAddress(body);
  }
}
