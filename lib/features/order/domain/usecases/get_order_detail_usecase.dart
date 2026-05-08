import '../entities/order_detail.dart';
import '../repositories/order_repository.dart';

/// Use case for fetching order detail
class GetOrderDetailUseCase {
  final OrderRepository repository;

  GetOrderDetailUseCase(this.repository);

  Future<OrderDetailEntity> call(String orderID) async {
    return await repository.getOrderDetail(orderID);
  }
}
