import '../../domain/entities/order_detail.dart';
import '../../domain/entities/order_history_response.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

/// Repository implementation for order operations
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrderHistoryResponseEntity> getOrderHistory({
    required int page,
    int limit = 10,
    String? orderID,
    String? status,
    String? paymentStatus,
    String? sortField,
    String? sortOrder,
  }) async {
    final model = await remoteDataSource.getOrderHistory(
      page: page,
      limit: limit,
      orderID: orderID,
      status: status,
      paymentStatus: paymentStatus,
      sortField: sortField,
      sortOrder: sortOrder,
    );
    return model;
  }

  @override
  Future<OrderDetailEntity> getOrderDetail(String orderID) async {
    final model = await remoteDataSource.getOrderDetail(orderID);
    return model;
  }

  @override
  Future<void> sendInvoiceEmail(String orderID) async {
    await remoteDataSource.sendInvoiceEmail(orderID);
  }

  @override
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body) async {
    return await remoteDataSource.placeOrder(body);
  }

  @override
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    int? cartID,
  }) async {
    return await remoteDataSource.applyCoupon(
      couponCode: couponCode,
      cartID: cartID,
    );
  }

  @override
  Future<void> returnOrder({
    required String orderID,
    String? orderItemID,
    required String returnType,
    required String returnReason,
    String? returnComments,
    List<String>? returnPhotos,
  }) async {
    await remoteDataSource.returnOrder(
      orderID: orderID,
      orderItemID: orderItemID,
      returnType: returnType,
      returnReason: returnReason,
      returnComments: returnComments,
      returnPhotos: returnPhotos,
    );
  }
}
