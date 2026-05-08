import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/presale_product_detail_model.dart';
import '../models/presale_response_model.dart';
import '../models/presale_booking_model.dart';

abstract class PresaleRemoteDataSource {
  Future<PresaleResponseModel> getPresaleProducts({int page = 1, int limit = 10});
  Future<PresaleProductDetailModel> getPresaleProductDetail(String productID);
  Future<Map<String, dynamic>> placePrebookingOrder({
    required String addressID,
    required String productID,
    String? variationID,
    required String paymentMode,
    int quantity = 1,
  });

  /// Get user's presale bookings
  Future<List<PresaleBookingModel>> getUserPresaleBookings();

  /// Get specific presale booking details
  Future<PresaleBookingModel> getPresaleBookingDetails(String preBookingID);
}

class PresaleRemoteDataSourceImpl implements PresaleRemoteDataSource {
  final Dio dio;

  PresaleRemoteDataSourceImpl({required this.dio});

  @override
  Future<PresaleResponseModel> getPresaleProducts({int page = 1, int limit = 10}) async {
    try {
      final response = await dio.get(
        '/api/presale/products/paginated',
        queryParameters: {'page': page, 'limit': limit},
      );
      return PresaleResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<PresaleProductDetailModel> getPresaleProductDetail(String productID) async {
    try {
      final response = await dio.get('/api/presale/products/$productID');
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] == true && data['data'] != null) {
        final productData = data['data'];
        
        // Handle both single object and list of one object (common API variation)
        if (productData is Map<String, dynamic>) {
          return PresaleProductDetailModel.fromJson(productData);
        } else if (productData is List && productData.isNotEmpty) {
          return PresaleProductDetailModel.fromJson(productData.first as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to load presale product details');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> placePrebookingOrder({
    required String addressID,
    required String productID,
    String? variationID,
    required String paymentMode,
    int quantity = 1,
  }) async {
    try {
      final response = await dio.post('/api/presale/place-prebooking-order', data: {
        'addressID': addressID,
        'productID': productID,
        'variationID': variationID,
        'paymentMode': paymentMode,
        'quantity': quantity,
        'device': 'app', // Standard for PhonePe token flow
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<List<PresaleBookingModel>> getUserPresaleBookings() async {
    try {
      final response = await dio.get('/api/presale/my-bookings');
      final data = response.data as Map<String, dynamic>;
      
      debugPrint('[PRESALE REMOTE] getUserPresaleBookings status: ${data['success']}');
      
      if (data['success'] == true) {
        final List bookings = data['bookings'] ?? [];
        debugPrint('[PRESALE REMOTE] Found ${bookings.length} bookings');
        return bookings.map((b) => PresaleBookingModel.fromJson(b as Map<String, dynamic>)).toList();
      }
      
      debugPrint('[PRESALE REMOTE] API error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to load bookings');
    } on DioException catch (e) {
      debugPrint('[PRESALE REMOTE] Dio error: ${e.message}');
      debugPrint('[PRESALE REMOTE] Dio response: ${e.response?.data}');
      throw Exception(_extractErrorMessage(e));
    } catch (e, stack) {
      debugPrint('[PRESALE REMOTE] Parsing error: $e');
      debugPrint('[PRESALE REMOTE] Stack trace: $stack');
      throw Exception('Failed to parse bookings: $e');
    }
  }

  @override
  Future<PresaleBookingModel> getPresaleBookingDetails(String preBookingID) async {
    try {
      final response = await dio.get('/api/presale/booking-details/$preBookingID');
      final data = response.data as Map<String, dynamic>;
      
      debugPrint('[PRESALE REMOTE] getPresaleBookingDetails status: ${data['success']}');
      
      if (data['success'] == true) {
        final orderDetail = data['orderDetail'] as Map<String, dynamic>;
        orderDetail['items'] = data['items'];
        return PresaleBookingModel.fromJson(orderDetail);
      }
      
      debugPrint('[PRESALE REMOTE] API error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to load booking details');
    } on DioException catch (e) {
      debugPrint('[PRESALE REMOTE] Dio error: ${e.message}');
      debugPrint('[PRESALE REMOTE] Dio response: ${e.response?.data}');
      throw Exception(_extractErrorMessage(e));
    } catch (e, stack) {
      debugPrint('[PRESALE REMOTE] Parsing error: $e');
      debugPrint('[PRESALE REMOTE] Stack trace: $stack');
      throw Exception('Failed to parse booking details: $e');
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'An unexpected error occurred';
      }
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
