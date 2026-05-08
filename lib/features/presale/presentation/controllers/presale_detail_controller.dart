import '../providers/presale_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/presale_repository.dart';
import '../state/presale_detail_state.dart';
import '../../../product_detail/variable/domain/entities/variation.dart';

class PresaleDetailController extends StateNotifier<PresaleDetailState> {
  final PresaleRepository repository;
  final String productID;
  bool _hasFetched = false;

  PresaleDetailController(this.repository, {required this.productID})
      : super(const PresaleDetailState()) {
    loadProductDetail();
  }

  Future<void> loadProductDetail() async {
    if (_hasFetched) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final productDetail = await repository.getPresaleProductDetail(productID);
      _hasFetched = true;
      state = state.copyWith(productDetail: productDetail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectVariation(VariationEntity variation) {
    final Map<String, String> attributes = {};
    for (final attr in variation.attributes) {
      attributes[attr.attributeName] = attr.attributeValue;
    }
    state = state.copyWith(
      selectedVariation: variation,
      selectedAttributes: attributes,
    );
  }

  void updateSelectedAttributes(Map<String, String> attributes) {
    state = state.copyWith(selectedAttributes: attributes);
  }

  void updateQuantity(int quantity) {
    if (quantity >= 1) {
      state = state.copyWith(quantity: quantity);
    }
  }
}

final presaleDetailControllerProvider = StateNotifierProvider.autoDispose.family<
    PresaleDetailController, PresaleDetailState, String>((ref, productID) {
  final repository = ref.watch(presaleRepositoryProvider);
  return PresaleDetailController(repository, productID: productID);
});
