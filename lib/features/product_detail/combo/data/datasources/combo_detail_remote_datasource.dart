import 'package:dio/dio.dart';
import '../models/combo_detail_model.dart';
import 'package:flutter/foundation.dart';
/// Remote data source for combo detail API
abstract class ComboDetailRemoteDataSource {
  Future<ComboDetailModel> getComboDetail(String comboID);
}

class ComboDetailRemoteDataSourceImpl implements ComboDetailRemoteDataSource {
  final Dio dio;

  ComboDetailRemoteDataSourceImpl({required this.dio});

  @override
  Future<ComboDetailModel> getComboDetail(String comboID) async {
    // Validate comboID
    if (comboID.isEmpty) {
      throw Exception('Invalid combo ID: Combo ID cannot be empty.');
    }

    debugPrint('[COMBO DETAIL DATA SOURCE] Fetching combo detail for ID: $comboID');

    try {
      // Ensure comboID is complete and properly formatted in the URL
      final endpoint = '/api/combo/detail-user/$comboID';
      debugPrint('[COMBO DETAIL DATA SOURCE] Making GET request to $endpoint');
      final response = await dio.get(endpoint);

      debugPrint('[COMBO DETAIL DATA SOURCE] Response received successfully');
      debugPrint(
        '[COMBO DETAIL DATA SOURCE] Response status: ${response.statusCode}',
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        // API returns data in 'data' field: {"success": true, "data": {...}}
        final comboData = responseData['data'] as Map<String, dynamic>?;
        if (comboData == null) {
          throw Exception('Combo data not found in API response');
        }
        final comboDetail = ComboDetailModel.fromJson(comboData);
        debugPrint(
          '[COMBO DETAIL DATA SOURCE] Successfully parsed combo detail: ${comboDetail.productName}',
        );
        return comboDetail;
      } else {
        throw Exception('Invalid response format from combo detail API');
      }
    } on DioException catch (e) {
      debugPrint('[COMBO DETAIL DATA SOURCE] Error occurred: ${e.message}');
      debugPrint('[COMBO DETAIL DATA SOURCE] Error type: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '[COMBO DETAIL DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[COMBO DETAIL DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint(
        '[COMBO DETAIL DATA SOURCE] Extracted error message: $errorMessage',
      );
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[COMBO DETAIL DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final error = data['error'] as String?;
        if (error != null && error.isNotEmpty) {
          return error;
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid combo ID.';
        case 404:
          return 'Combo not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed with status $statusCode';
      }
    }

    return e.message ?? 'An unexpected error occurred';
  }
}
