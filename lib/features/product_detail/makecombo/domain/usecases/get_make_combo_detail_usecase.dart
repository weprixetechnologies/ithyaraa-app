import '../../../combo/domain/entities/combo_detail.dart';
import '../repositories/make_combo_detail_repository.dart';

class GetMakeComboDetailUseCase {
  final MakeComboDetailRepository repository;

  GetMakeComboDetailUseCase(this.repository);

  Future<ComboDetailEntity> call(String productID) async {
    return await repository.getMakeComboDetail(productID);
  }
}
