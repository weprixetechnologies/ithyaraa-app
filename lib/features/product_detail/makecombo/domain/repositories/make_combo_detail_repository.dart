import '../../../combo/domain/entities/combo_detail.dart';

/// Repository interface for Make Combo detail
abstract class MakeComboDetailRepository {
  Future<ComboDetailEntity> getMakeComboDetail(String productID);
}
