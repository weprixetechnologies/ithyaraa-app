import '../../domain/repositories/make_combo_detail_repository.dart';
import '../../../combo/domain/entities/combo_detail.dart';
import '../datasources/make_combo_detail_remote_datasource.dart';

class MakeComboDetailRepositoryImpl implements MakeComboDetailRepository {
  final MakeComboDetailRemoteDataSource remoteDataSource;

  MakeComboDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ComboDetailEntity> getMakeComboDetail(String productID) async {
    return await remoteDataSource.getMakeComboDetail(productID);
  }
}
