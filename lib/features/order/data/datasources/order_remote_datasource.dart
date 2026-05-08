import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/order_detail_model.dart';
import '../models/order_history_response_model.dart';

OrderHistoryResponseModel _parseOrderHistoryResponse(Map<String, dynamic> data) {
  return OrderHistoryResponseModel.fromJson(data);
}

OrderDetailModel _parseOrderDetailResponse(Map<String, dynamic> data) {
  return OrderDetailModel.fromJson(data);
}

/// Remote data source for order API
abstract class OrderRemoteDataSource {
  Future<OrderHistoryResponseModel> getOrderHistory({
    required int page,
    int limit = 10,
    String? orderID,
    String? status,
    String? paymentStatus,
    String? sortField,
    String? sortOrder,
  });

  Future<OrderDetailModel> getOrderDetail(String orderID);

  Future<void> sendInvoiceEmail(String orderID);

  /// Place order from current cart selection
  ///
  /// Expects body to match `/api/order/place-order` docs exactly:
  /// {
  ///   "addressID": "ADDR123",
  ///   "paymentMode": "PREPAID",
  ///   "couponCode": "SAVE20",
  ///   "walletApplied": 100
  /// }
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body);

  /// Apply coupon against current cart
  ///
  /// Calls `/api/user-coupon/apply-coupon` and returns raw response map so
  /// presentation layer can display server-calculated totals/discounts.
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    int? cartID,
  });
  
  /// Submit return request for an item or entire order
  Future<void> returnOrder({
    required String orderID,
    String? orderItemID,
    required String returnType,
    required String returnReason,
    String? returnComments,
    List<String>? returnPhotos,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<OrderHistoryResponseModel> getOrderHistory({
    required int page,
    int limit = 10,
    String? orderID,
    String? status,
    String? paymentStatus,
    String? sortField,
    String? sortOrder,
  }) async {
    debugPrint('[ORDER DATA SOURCE] Fetching order history - Page: $page, Limit: $limit, OrderID: $orderID, Status: $status, PaymentStatus: $paymentStatus, SortField: $sortField, SortOrder: $sortOrder');

    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      // Add orderID if provided (for search - partial match)
      if (orderID != null && orderID.isNotEmpty) {
        queryParams['orderID'] = orderID;
      }
      
      // Add status if provided (exact match)
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      // Add paymentStatus if provided (exact match)
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['paymentStatus'] = paymentStatus;
      }
      
      // Add sortField if provided
      if (sortField != null && sortField.isNotEmpty) {
        queryParams['sortField'] = sortField;
      }
      
      // Add sortOrder if provided
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sortOrder'] = sortOrder.toLowerCase();
      }

      final response = await dio.get(
        '/api/order/get-order-summaries',
        queryParameters: queryParams,
      );

      debugPrint('[ORDER DATA SOURCE] Response received successfully');
      final responseData = response.data as Map<String, dynamic>;
      
      // Log full response for debugging
      debugPrint('[ORDER DATA SOURCE] Full response: $responseData');
      
      // Check success flag
      if (responseData['success'] == true) {
        // Log data array before parsing
        final dataArray = responseData['data'] as List?;
        debugPrint('[ORDER DATA SOURCE] Data array length: ${dataArray?.length ?? 0}');
        if (dataArray != null && dataArray.isNotEmpty) {
          debugPrint('[ORDER DATA SOURCE] First order item: ${dataArray.first}');
        }
        
        final historyResponse = await compute(_parseOrderHistoryResponse, responseData);
        debugPrint('[ORDER DATA SOURCE] Parsed ${historyResponse.orders.length} orders');
        return historyResponse;
      } else {
        throw Exception('API returned success: false');
      }
    } on DioException catch (e) {
      debugPrint('[ORDER DATA SOURCE] Error occurred: ${e.message}');
      if (e.response != null) {
        debugPrint('[ORDER DATA SOURCE] Error status code: ${e.response?.statusCode}');
        debugPrint('[ORDER DATA SOURCE] Error response data: ${e.response?.data}');
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint('[ORDER DATA SOURCE] Extracted error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[ORDER DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<OrderDetailModel> getOrderDetail(String orderID) async {
    debugPrint('[ORDER DATA SOURCE] Fetching order detail for ID: $orderID');

    try {
      final response = await dio.get('/api/order/order-details/$orderID');

      debugPrint('[ORDER DATA SOURCE] Response received successfully');
      final responseData = response.data as Map<String, dynamic>;
      
      // Log full response for debugging
      debugPrint('[ORDER DATA SOURCE] Full order detail response: $responseData');
      
      // Check success flag
      if (responseData['success'] == true) {
        final orderDetail = await compute(_parseOrderDetailResponse, responseData);
        debugPrint('[ORDER DATA SOURCE] Successfully parsed order detail: ${orderDetail.orderID}');
        return orderDetail;
      } else {
        throw Exception('API returned success: false');
      }
    } on DioException catch (e) {
      debugPrint('[ORDER DATA SOURCE] Error occurred: ${e.message}');
      if (e.response != null) {
        debugPrint('[ORDER DATA SOURCE] Error status code: ${e.response?.statusCode}');
        debugPrint('[ORDER DATA SOURCE] Error response data: ${e.response?.data}');
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint('[ORDER DATA SOURCE] Extracted error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[ORDER DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendInvoiceEmail(String orderID) async {
    debugPrint('[ORDER DATA SOURCE] Sending invoice email for order ID: $orderID');

    try {
      final response = await dio.post('/api/order/email-invoice/$orderID');

      debugPrint('[ORDER DATA SOURCE] Invoice email sent successfully');
      final responseData = response.data as Map<String, dynamic>?;
      
      // Check success flag if present
      if (responseData != null && responseData['success'] == false) {
        throw Exception(responseData['message'] as String? ?? 'Failed to send invoice email');
      }
    } on DioException catch (e) {
      debugPrint('[ORDER DATA SOURCE] Error sending invoice email: ${e.message}');
      if (e.response != null) {
        debugPrint('[ORDER DATA SOURCE] Error status code: ${e.response?.statusCode}');
        debugPrint('[ORDER DATA SOURCE] Error response data: ${e.response?.data}');
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint('[ORDER DATA SOURCE] Extracted error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[ORDER DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> placeOrder(
    Map<String, dynamic> body,
  ) async {
    debugPrint('[ORDER DATA SOURCE] Placing order with body: $body');

    try {
      final response = await dio.post(
        '/api/order/place-order',
        data: {
          ...body,
          'device': 'app',
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('[ORDER DATA SOURCE] Place order response: $responseData');
      return responseData;
    } on DioException catch (e) {
      debugPrint('[ORDER DATA SOURCE] Error placing order: ${e.message}');
      if (e.response != null) {
        debugPrint('[ORDER DATA SOURCE] Error status code: ${e.response?.statusCode}');
        debugPrint('[ORDER DATA SOURCE] Error response data: ${e.response?.data}');
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint('[ORDER DATA SOURCE] Extracted error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[ORDER DATA SOURCE] Unexpected error while placing order: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    int? cartID,
  }) async {
    debugPrint('[ORDER DATA SOURCE] Applying coupon: $couponCode for cartID: $cartID');

    try {
      final body = <String, dynamic>{
        'couponCode': couponCode,
        if (cartID != null) 'cartID': cartID,
      };

      final response = await dio.post(
        '/api/user-coupon/apply-coupon',
        data: body,
      );

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('[ORDER DATA SOURCE] Apply coupon response: $responseData');
      return responseData;
    } on DioException catch (e) {
      debugPrint('[ORDER DATA SOURCE] Error applying coupon: ${e.message}');
      if (e.response != null) {
        debugPrint('[ORDER DATA SOURCE] Error status code: ${e.response?.statusCode}');
        debugPrint('[ORDER DATA SOURCE] Error response data: ${e.response?.data}');
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint('[ORDER DATA SOURCE] Extracted error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[ORDER DATA SOURCE] Unexpected error while applying coupon: $e');
      rethrow;
    }
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
    debugPrint('[ORDER DATA SOURCE] Submitting return request - OrderID: $orderID, ItemID: $orderItemID');

    try {
      final body = <String, dynamic>{
        'orderID': orderID,
        if (orderItemID != null) 'orderItemID': orderItemID,
        'returnType': returnType,
        'returnReason': returnReason,
        if (returnComments != null) 'returnComments': returnComments,
        if (returnPhotos != null) 'returnPhotos': returnPhotos,
      };

      final response = await dio.post(
        '/api/order/return-order',
        data: body,
      );

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('[ORDER DATA SOURCE] Return order response: $responseData');

      if (responseData['success'] != true) {
        throw Exception(responseData['message'] as String? ?? 'Return request failed');
      }
    } on DioException catch (e) {
      debugPrint('[ORDER DATA SOURCE] Error submitting return: ${e.message}');
      if (e.response != null) {
        debugPrint('[ORDER DATA SOURCE] Error status code: ${e.response?.statusCode}');
        debugPrint('[ORDER DATA SOURCE] Error response data: ${e.response?.data}');
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint('[ORDER DATA SOURCE] Extracted error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[ORDER DATA SOURCE] Unexpected error while submitting return: $e');
      rethrow;
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 
               data['error'] as String? ?? 
               'Failed to fetch order data';
      } else if (data is String) {
        return data;
      }
    }
    return e.message ?? 'Network error occurred';
  }
}
