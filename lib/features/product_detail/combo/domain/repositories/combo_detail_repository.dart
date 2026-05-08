import '../entities/combo_detail.dart';

/// Repository interface for combo detail
abstract class ComboDetailRepository {
  Future<ComboDetailEntity> getComboDetail(String comboID);
}
