import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../combo/domain/entities/combo_product.dart';
import '../../../variable/domain/entities/variation.dart';
import '../../domain/usecases/get_make_combo_detail_usecase.dart';
import '../state/make_combo_detail_state.dart';

class MakeComboDetailController extends StateNotifier<MakeComboDetailState> {
  final GetMakeComboDetailUseCase getMakeComboDetailUseCase;
  final String productID;
  bool _hasFetched = false;

  MakeComboDetailController(
    this.getMakeComboDetailUseCase, {
    required this.productID,
  }) : super(const MakeComboDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (_hasFetched) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final detail = await getMakeComboDetailUseCase(productID);
      _hasFetched = true;
      state = state.copyWith(detail: detail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Apply selection from modal: set selected products and auto-resolve
  /// first in-stock variation for each product that has variations.
  void applySelection(List<ComboProductEntity> products) {
    if (state.detail == null || products.isEmpty) return;
    final maxProducts = products.length > MakeComboDetailState.maxProducts
        ? MakeComboDetailState.maxProducts
        : products.length;
    final selected = products.take(maxProducts).toList();

    final newAttributes = <String, Map<String, String>>{};
    final newVariations = <String, String?>{};

    for (final p in selected) {
      if (p.variations.isNotEmpty) {
        VariationEntity? firstInStock;
        for (final v in p.variations) {
          if (v.inStock && v.stockQuantity > 0) {
            firstInStock = v;
            break;
          }
        }
        if (firstInStock != null) {
          final attrs = <String, String>{};
          for (final a in firstInStock.attributes) {
            attrs[a.attributeName] = a.attributeValue;
          }
          newAttributes[p.productID] = attrs;
          newVariations[p.productID] = firstInStock.variationID;
        }
      }
    }

    state = state.copyWith(
      selectedProducts: selected,
      selectedAttributes: newAttributes,
      selectedVariations: newVariations,
    );
  }

  /// Update selected attributes for a product and resolve variation (same as combo).
  void updateSelectedAttributes(
    String productID,
    Map<String, String> attributes,
  ) {
    if (state.detail == null) return;
    ComboProductEntity? product;
    try {
      product = state.detail!.products.firstWhere(
        (p) => p.productID == productID,
      );
    } catch (_) {
      return;
    }

    final updatedAttributes = Map<String, Map<String, String>>.from(
      state.selectedAttributes,
    );
    updatedAttributes[productID] = Map<String, String>.from(attributes);

    final resolvedVariationID = _resolveVariationFromAttributes(
      product,
      attributes,
    );

    final updatedVariations = Map<String, String?>.from(
      state.selectedVariations,
    );
    updatedVariations[productID] = resolvedVariationID;

    state = state.copyWith(
      selectedAttributes: updatedAttributes,
      selectedVariations: updatedVariations,
    );
  }

  String? _resolveVariationFromAttributes(
    ComboProductEntity product,
    Map<String, String> selectedAttributes,
  ) {
    if (selectedAttributes.isEmpty) return null;
    final matching = product.variations.where((v) {
      for (final e in selectedAttributes.entries) {
        final hasMatch = v.attributes.any(
          (a) => a.attributeName == e.key && a.attributeValue == e.value,
        );
        if (!hasMatch) return false;
      }
      return true;
    }).toList();
    if (matching.isEmpty) return null;
    for (final v in matching) {
      if (v.stockQuantity > 0) return v.variationID;
    }
    return null;
  }

  void removeProduct(String productID) {
    final newList = state.selectedProducts
        .where((p) => p.productID != productID)
        .toList();
    final newAttributes = Map<String, Map<String, String>>.from(
      state.selectedAttributes,
    );
    newAttributes.remove(productID);
    final newVariations = Map<String, String?>.from(state.selectedVariations);
    newVariations.remove(productID);
    state = state.copyWith(
      selectedProducts: newList,
      selectedAttributes: newAttributes,
      selectedVariations: newVariations,
    );
  }

  void updateQuantity(int quantity) {
    if (quantity < 1) return;
    state = state.copyWith(quantity: quantity);
  }

  void retry() {
    _hasFetched = false;
    loadDetail();
  }
}
