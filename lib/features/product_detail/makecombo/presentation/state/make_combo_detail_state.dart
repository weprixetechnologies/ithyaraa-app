import '../../../combo/domain/entities/combo_detail.dart';
import '../../../combo/domain/entities/combo_product.dart';
import '../../../variable/domain/entities/variation.dart';

/// State for Make Combo PDP.
/// selectedProducts: user-selected products (max 3, min 1 for add to cart).
/// selectedAttributes: map from productID to attribute name->value.
/// selectedVariations: map from productID to variationID (resolved from attributes).
class MakeComboDetailState {
  final ComboDetailEntity? detail;
  final bool isLoading;
  final String? error;
  final List<ComboProductEntity> selectedProducts;
  final Map<String, Map<String, String>> selectedAttributes;
  final Map<String, String?> selectedVariations;
  final int quantity;

  static const int maxProducts = 3;
  static const int minProducts = 1;

  const MakeComboDetailState({
    this.detail,
    this.isLoading = false,
    this.error,
    this.selectedProducts = const [],
    this.selectedAttributes = const {},
    this.selectedVariations = const {},
    this.quantity = 1,
  });

  MakeComboDetailState copyWith({
    ComboDetailEntity? detail,
    bool? isLoading,
    String? error,
    List<ComboProductEntity>? selectedProducts,
    Map<String, Map<String, String>>? selectedAttributes,
    Map<String, String?>? selectedVariations,
    int? quantity,
  }) {
    return MakeComboDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      selectedVariations: selectedVariations ?? this.selectedVariations,
      quantity: quantity ?? this.quantity,
    );
  }

  /// True if every selected product has a valid (in-stock) variation selected.
  bool get allVariationsValid {
    if (detail == null || selectedProducts.isEmpty) return false;
    for (final p in selectedProducts) {
      if (p.variations.isNotEmpty) {
        final vid = selectedVariations[p.productID];
        if (vid == null || vid.isEmpty) return false;
        try {
          final v = p.variations.firstWhere((v) => v.variationID == vid);
          if (!v.inStock || v.stockQuantity <= 0) return false;
        } catch (_) {
          return false;
        }
      }
    }
    return true;
  }

  /// True if add to cart is allowed: at least one product, all have valid variation.
  bool get canAddToCart =>
      selectedProducts.isNotEmpty && allVariationsValid && quantity > 0;

  /// Build products array for add-cart-combo payload.
  List<Map<String, String>> buildProductsArray() {
    final list = <Map<String, String>>[];
    for (final p in selectedProducts) {
      final vid = selectedVariations[p.productID];
      if (vid != null && vid.isNotEmpty) {
        list.add({'productID': p.productID, 'variationID': vid});
      }
    }
    return list;
  }

  Map<String, String> getSelectedAttributes(String productID) {
    return selectedAttributes[productID] ?? {};
  }

  VariationEntity? getSelectedVariation(String productID) {
    if (detail == null) return null;
    final vid = selectedVariations[productID];
    if (vid == null || vid.isEmpty) return null;
    try {
      final product = detail!.products.firstWhere(
        (p) => p.productID == productID,
      );
      return product.variations.firstWhere((v) => v.variationID == vid);
    } catch (_) {
      return null;
    }
  }

  /// Whether product with [productID] is in selected list.
  bool isProductSelected(String productID) {
    return selectedProducts.any((p) => p.productID == productID);
  }
}
