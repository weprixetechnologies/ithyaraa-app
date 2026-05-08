import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';

/// Repository implementation for address operations
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Address>> getAllAddresses() async {
    final models = await remoteDataSource.getAllAddresses();
    return models;
  }

  @override
  Future<void> addAddress(Map<String, dynamic> body) async {
    await remoteDataSource.addAddress(body);
  }
}
