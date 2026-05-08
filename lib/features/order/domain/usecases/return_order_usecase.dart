import '../repositories/order_repository.dart';

/// Use case for submitting a return request
class ReturnOrderUseCase {
  final OrderRepository repository;

  ReturnOrderUseCase({required this.repository});

  Future<void> call({
    required String orderID,
    String? orderItemID,
    required String returnType,
    required String returnReason,
    String? returnComments,
    List<String>? returnPhotos,
  }) async {
    return await repository.returnOrder(
      orderID: orderID,
      orderItemID: orderItemID,
      returnType: returnType,
      returnReason: returnReason,
      returnComments: returnComments,
      returnPhotos: returnPhotos,
    );
  }
}
