import '../../domain/entities/presale_product_detail.dart';
import '../../../product_detail/variable/domain/entities/variation.dart';

class PresaleDetailState {
  final PresaleProductDetailEntity? productDetail;
  final bool isLoading;
  final String? error;
  final VariationEntity? selectedVariation;
  final Map<String, String> selectedAttributes;
  final int quantity;

  const PresaleDetailState({
    this.productDetail,
    this.isLoading = false,
    this.error,
    this.selectedVariation,
    this.selectedAttributes = const {},
    this.quantity = 1,
  });

  PresaleDetailState copyWith({
    PresaleProductDetailEntity? productDetail,
    bool? isLoading,
    String? error,
    VariationEntity? selectedVariation,
    Map<String, String>? selectedAttributes,
    int? quantity,
  }) {
    return PresaleDetailState(
      productDetail: productDetail ?? this.productDetail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedVariation: selectedVariation ?? this.selectedVariation,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      quantity: quantity ?? this.quantity,
    );
  }

  double? get displayPrice {
    if (selectedVariation?.overridePrice != null) return selectedVariation!.overridePrice;
    if (selectedVariation?.salePrice != null) return selectedVariation!.salePrice;
    return productDetail?.salePrice;
  }

  double? get displayRegularPrice {
    if (selectedVariation?.regularPrice != null) return selectedVariation!.regularPrice;
    return productDetail?.regularPrice;
  }

  bool get isInStock {
    if (selectedVariation != null) return selectedVariation!.inStock;
    return productDetail?.inStock ?? false;
  }
}
