import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/entities/variation.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';

/// Product detail page state
class ProductDetailState {
  final ProductDetailEntity? productDetail;
  final bool isLoading;
  final String? error;
  final VariationEntity? selectedVariation;
  final Map<String, String> selectedAttributes; // Track partial selections

  const ProductDetailState({
    this.productDetail,
    this.isLoading = false,
    this.error,
    this.selectedVariation,
    this.selectedAttributes = const {},
  });

  ProductDetailState copyWith({
    ProductDetailEntity? productDetail,
    bool? isLoading,
    String? error,
    VariationEntity? selectedVariation,
    Map<String, String>? selectedAttributes,
  }) {
    return ProductDetailState(
      productDetail: productDetail ?? this.productDetail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedVariation: selectedVariation ?? this.selectedVariation,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
    );
  }

  /// Get current display price (variation override or product price)
  double? get displayPrice {
    if (selectedVariation?.overridePrice != null) {
      return selectedVariation!.overridePrice;
    }
    if (selectedVariation?.salePrice != null) {
      return selectedVariation!.salePrice;
    }
    if (productDetail?.overridePrice != null) {
      return productDetail!.overridePrice;
    }
    return productDetail?.salePrice;
  }

  /// Get current display regular price
  double? get displayRegularPrice {
    if (selectedVariation?.regularPrice != null) {
      return selectedVariation!.regularPrice;
    }
    return productDetail?.regularPrice;
  }

  /// Get current stock status
  bool get isInStock {
    if (selectedVariation != null) {
      return selectedVariation!.inStock;
    }
    return productDetail?.inStock ?? false;
  }
}

/// Product detail controller managing product detail page state
class ProductDetailController extends StateNotifier<ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;
  final String productID;
  bool _hasFetched = false;

  ProductDetailController(
    this.getProductDetailUseCase, {
    required this.productID,
  }) : super(const ProductDetailState()) {
    loadProductDetail();
  }

  /// Load product detail (only once per page entry)
  Future<void> loadProductDetail() async {
    if (_hasFetched) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final productDetail = await getProductDetailUseCase(productID);
      _hasFetched = true;
      state = state.copyWith(productDetail: productDetail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Select a variation
  void selectVariation(VariationEntity variation) {
    // Extract attributes from variation
    final Map<String, String> attributes = {};
    for (final attr in variation.attributes) {
      attributes[attr.attributeName] = attr.attributeValue;
    }
    state = state.copyWith(
      selectedVariation: variation,
      selectedAttributes: attributes,
    );
  }

  /// Update selected attributes (for partial selections)
  void updateSelectedAttributes(Map<String, String> attributes) {
    state = state.copyWith(selectedAttributes: attributes);
  }

  /// Clear selected variation
  void clearVariation() {
    state = state.copyWith(selectedVariation: null, selectedAttributes: {});
  }
}
