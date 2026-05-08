import '../../domain/repositories/combo_detail_repository.dart';
import '../../domain/entities/combo_detail.dart';
import '../datasources/combo_detail_remote_datasource.dart';

/// Repository implementation for combo detail
class ComboDetailRepositoryImpl implements ComboDetailRepository {
  final ComboDetailRemoteDataSource remoteDataSource;

  ComboDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ComboDetailEntity> getComboDetail(String comboID) async {
    return await remoteDataSource.getComboDetail(comboID);
  }
}
