import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/combo_detail.dart';
import '../../domain/entities/combo_product.dart';
import '../../domain/usecases/get_combo_detail_usecase.dart';
import '../../../variable/domain/entities/variation.dart';

/// Combo detail page state
class ComboDetailState {
  final ComboDetailEntity? comboDetail;
  final bool isLoading;
  final String? error;
  final Map<String, Map<String, String>>
  selectedAttributesPerProduct; // Map<productID, Map<attributeName, attributeValue>>
  final Map<String, String?>
  selectedVariations; // Map<productID, variationID> (resolved from attributes)
  final int quantity;

  const ComboDetailState({
    this.comboDetail,
    this.isLoading = false,
    this.error,
    this.selectedAttributesPerProduct = const {},
    this.selectedVariations = const {},
    this.quantity = 1,
  });

  ComboDetailState copyWith({
    ComboDetailEntity? comboDetail,
    bool? isLoading,
    String? error,
    Map<String, Map<String, String>>? selectedAttributesPerProduct,
    Map<String, String?>? selectedVariations,
    int? quantity,
  }) {
    return ComboDetailState(
      comboDetail: comboDetail ?? this.comboDetail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAttributesPerProduct:
          selectedAttributesPerProduct ?? this.selectedAttributesPerProduct,
      selectedVariations: selectedVariations ?? this.selectedVariations,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Check if all products have selected variations
  /// Validation: ALL products with variations MUST have a non-null, non-empty variationID
  bool get allVariationsSelected {
    if (comboDetail == null || comboDetail!.products.isEmpty) return false;

    // Count products that require variations
    int productsRequiringVariations = 0;
    int productsWithValidVariations = 0;

    for (final product in comboDetail!.products) {
      if (product.variations.isNotEmpty) {
        productsRequiringVariations++;
        final selectedVariationID = selectedVariations[product.productID];
        if (selectedVariationID != null && selectedVariationID.isNotEmpty) {
          productsWithValidVariations++;
        }
      }
    }

    // All products requiring variations must have valid selections
    return productsRequiringVariations > 0 &&
        productsRequiringVariations == productsWithValidVariations;
  }

  /// Validate that products array will match comboDetail.products.length
  /// Returns true if validation passes, false otherwise
  bool validateProductsArray() {
    if (comboDetail == null || comboDetail!.products.isEmpty) return false;

    // Count products that require variations
    final productsRequiringVariations = comboDetail!.products
        .where((p) => p.variations.isNotEmpty)
        .length;

    // Count valid selected variations
    final validSelections = selectedVariations.values
        .where((variationID) => variationID != null && variationID!.isNotEmpty)
        .length;

    // Must match exactly
    return productsRequiringVariations == validSelections;
  }

  /// Build products array for add-to-cart payload
  /// Returns empty list if validation fails
  List<Map<String, String>> buildProductsArray() {
    if (!validateProductsArray()) {
      return [];
    }

    final products = <Map<String, String>>[];
    for (final entry in selectedVariations.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        products.add({'productID': entry.key, 'variationID': entry.value!});
      }
    }
    return products;
  }

  /// Get selected attributes for a product
  Map<String, String> getSelectedAttributes(String productID) {
    return selectedAttributesPerProduct[productID] ?? {};
  }

  /// Get selected variation for a product (resolved from attributes)
  VariationEntity? getSelectedVariation(String productID) {
    final variationID = selectedVariations[productID];
    if (variationID == null || variationID.isEmpty) return null;

    try {
      final product = comboDetail?.products.firstWhere(
        (p) => p.productID == productID,
      );

      if (product == null) return null;

      final finalVariationID = variationID; // Local variable for null safety
      try {
        return product.variations.firstWhere(
          (v) => v.variationID == finalVariationID,
        );
      } catch (e) {
        // Variation not found, return null
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

/// Combo detail controller managing combo detail page state
class ComboDetailController extends StateNotifier<ComboDetailState> {
  final GetComboDetailUseCase getComboDetailUseCase;
  final String productID;
  bool _hasFetched = false;

  ComboDetailController(this.getComboDetailUseCase, {required this.productID})
    : super(const ComboDetailState()) {
    loadComboDetail();
  }

  /// Load combo detail (only once per page entry)
  Future<void> loadComboDetail() async {
    if (_hasFetched) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final comboDetail = await getComboDetailUseCase(productID);
      _hasFetched = true;
      state = state.copyWith(comboDetail: comboDetail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update selected attributes for a product and resolve variation
  /// Matches website behavior: attributes → filter variations → check stock → resolve
  void updateSelectedAttributes(
    String productID,
    Map<String, String> attributes,
  ) {
    final product = state.comboDetail?.products.firstWhere(
      (p) => p.productID == productID,
      orElse: () => throw Exception('Product not found'),
    );

    if (product == null) return;

    // Update selected attributes
    final updatedAttributes = Map<String, Map<String, String>>.from(
      state.selectedAttributesPerProduct,
    );
    updatedAttributes[productID] = Map<String, String>.from(attributes);

    // Resolve variation from attributes (website matching logic)
    String? resolvedVariationID = _resolveVariationFromAttributes(
      product,
      attributes,
    );

    // Update both attributes and resolved variation
    final updatedVariations = Map<String, String?>.from(
      state.selectedVariations,
    );
    updatedVariations[productID] = resolvedVariationID;

    state = state.copyWith(
      selectedAttributesPerProduct: updatedAttributes,
      selectedVariations: updatedVariations,
    );
  }

  /// Resolve variation from selected attributes (matches website logic)
  /// Rules:
  /// 1. Filter variations where variation.attributes matches all selected attributes
  /// 2. Only resolve if variationStock > 0
  /// 3. Take first matching variation
  /// 4. Return null if no match or all matches are out of stock
  String? _resolveVariationFromAttributes(
    ComboProductEntity product,
    Map<String, String> selectedAttributes,
  ) {
    if (selectedAttributes.isEmpty) return null;

    // Filter variations that match all selected attributes
    final matchingVariations = product.variations.where((variation) {
      // Check if variation has all selected attributes matching
      for (final entry in selectedAttributes.entries) {
        final hasMatch = variation.attributes.any(
          (attr) =>
              attr.attributeName == entry.key &&
              attr.attributeValue == entry.value,
        );
        if (!hasMatch) return false;
      }
      return true;
    }).toList();

    if (matchingVariations.isEmpty) return null;

    // Find first variation with stock > 0 (website behavior)
    for (final variation in matchingVariations) {
      if (variation.stockQuantity > 0) {
        return variation.variationID;
      }
    }

    // All matching variations are out of stock - return null (silent failure)
    return null;
  }

  /// Clear variation selection for a product
  void clearVariation(String productID) {
    final updatedAttributes = Map<String, Map<String, String>>.from(
      state.selectedAttributesPerProduct,
    );
    updatedAttributes.remove(productID);

    final updatedVariations = Map<String, String?>.from(
      state.selectedVariations,
    );
    updatedVariations[productID] = null;

    state = state.copyWith(
      selectedAttributesPerProduct: updatedAttributes,
      selectedVariations: updatedVariations,
    );
  }

  /// Update quantity
  void updateQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
  }
}
