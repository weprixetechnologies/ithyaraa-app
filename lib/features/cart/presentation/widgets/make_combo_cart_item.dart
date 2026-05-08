import 'combo_cart_item.dart';

/// Make Combo Cart Item Widget
/// 
/// Renders a make-combo product (user-selected combo).
/// Identical structure to ComboCartItem - both show parent + nested children.
/// 
/// Hierarchy: Parent item + nested comboItems (children)
/// Pricing: Parent level only (children have no pricing)
class MakeComboCartItem extends ComboCartItem {
  const MakeComboCartItem({
    super.key,
    required super.item,
  });

  // Reuses ComboCartItem rendering logic - make_combo and combo are identical
}
