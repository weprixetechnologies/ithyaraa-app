import '../entities/combo_detail.dart';
import '../repositories/combo_detail_repository.dart';

/// Use case for fetching combo detail
class GetComboDetailUseCase {
  final ComboDetailRepository repository;

  GetComboDetailUseCase(this.repository);

  Future<ComboDetailEntity> call(String comboID) async {
    return await repository.getComboDetail(comboID);
  }
}
