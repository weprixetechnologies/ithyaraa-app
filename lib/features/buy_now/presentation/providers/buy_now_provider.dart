import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/buy_now_remote_datasource.dart';
import '../state/buy_now_state.dart';
import '../controllers/buy_now_controller.dart';
import '../../../order/presentation/providers/order_providers.dart';

final buyNowRemoteDataSourceProvider = Provider<BuyNowRemoteDataSource>((ref) {
  final dio = ref.read(orderDioProvider);
  return BuyNowRemoteDataSourceImpl(dio);
});

final buyNowProvider = StateNotifierProvider.autoDispose.family<BuyNowNotifier, BuyNowState, BuyNowState>((ref, initialState) {
  final remoteDataSource = ref.read(buyNowRemoteDataSourceProvider);
  return BuyNowNotifier(remoteDataSource, ref, initialState);
});
