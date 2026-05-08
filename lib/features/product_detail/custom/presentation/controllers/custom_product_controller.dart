import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/custom_product_detail.dart';
import '../../domain/entities/dress_type.dart';
import '../../domain/usecases/get_custom_product_detail_usecase.dart';

class CustomProductState {
  final CustomProductDetailEntity? productDetail;
  final bool isLoading;
  final String? error;
  
  final Map<String, dynamic> customInputValues;
  final DressTypeEntity? selectedDressType;
  final String? uploadedImageUrl;
  final bool isUploading;

  const CustomProductState({
    this.productDetail,
    this.isLoading = false,
    this.error,
    this.customInputValues = const {},
    this.selectedDressType,
    this.uploadedImageUrl,
    this.isUploading = false,
  });

  CustomProductState copyWith({
    CustomProductDetailEntity? productDetail,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? customInputValues,
    DressTypeEntity? selectedDressType,
    String? uploadedImageUrl,
    bool? isUploading,
  }) {
    return CustomProductState(
      productDetail: productDetail ?? this.productDetail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      customInputValues: customInputValues ?? this.customInputValues,
      selectedDressType: selectedDressType ?? this.selectedDressType,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  double? get displayPrice {
    if (selectedDressType != null) {
      return selectedDressType!.price;
    }
    if (productDetail?.overridePrice != null) {
      return productDetail!.overridePrice;
    }
    return productDetail?.salePrice;
  }

  bool get isInStock {
    return productDetail?.inStock ?? false;
  }
}

class CustomProductController extends StateNotifier<CustomProductState> {
  final GetCustomProductDetailUseCase getCustomProductDetailUseCase;
  final String productID;
  bool _hasFetched = false;

  CustomProductController(
    this.getCustomProductDetailUseCase, {
    required this.productID,
  }) : super(const CustomProductState()) {
    loadProductDetail();
  }

  Future<void> loadProductDetail() async {
    if (_hasFetched) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final productDetail = await getCustomProductDetailUseCase(productID);
      _hasFetched = true;
      state = state.copyWith(productDetail: productDetail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateCustomInput(String inputId, dynamic value) {
    if (state.customInputValues[inputId] == value) return;
    
    final updatedMap = Map<String, dynamic>.from(state.customInputValues);
    if (value == null || (value is String && value.trim().isEmpty)) {
      updatedMap.remove(inputId);
    } else {
      updatedMap[inputId] = value;
    }
    
    state = state.copyWith(customInputValues: updatedMap);
  }

  void selectDressType(DressTypeEntity dressType) {
    state = state.copyWith(selectedDressType: dressType);
  }

  void setUploadingImage(bool status) {
    state = state.copyWith(isUploading: status);
  }

  void setUploadedImageUrl(String url) {
    state = state.copyWith(uploadedImageUrl: url, isUploading: false);
  }

  void removeUploadedImage() {
    state = state.copyWith(uploadedImageUrl: null);
  }
}
