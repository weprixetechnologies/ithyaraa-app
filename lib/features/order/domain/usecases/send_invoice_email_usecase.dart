import '../repositories/order_repository.dart';

/// Use case for sending invoice email
class SendInvoiceEmailUseCase {
  final OrderRepository repository;

  SendInvoiceEmailUseCase(this.repository);

  Future<void> call(String orderID) async {
    return await repository.sendInvoiceEmail(orderID);
  }
}
