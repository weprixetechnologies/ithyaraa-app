import '../entities/address.dart';
import '../repositories/address_repository.dart';

/// Use case for fetching all addresses
class GetAllAddressesUseCase {
  final AddressRepository repository;

  GetAllAddressesUseCase(this.repository);

  Future<List<Address>> call() async {
    return await repository.getAllAddresses();
  }
}
