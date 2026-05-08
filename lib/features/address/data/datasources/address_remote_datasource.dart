import 'package:dio/dio.dart';
import '../models/address_model.dart';
import 'package:flutter/foundation.dart';

/// Remote data source for address API
abstract class AddressRemoteDataSource {
  /// Get all addresses for authenticated user
  Future<List<AddressModel>> getAllAddresses();

  /// Add a new address
  Future<void> addAddress(Map<String, dynamic> body);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final Dio dio;

  AddressRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AddressModel>> getAllAddresses() async {
    debugPrint('[ADDRESS DATA SOURCE] Fetching all addresses');

    try {
      final response = await dio.get('/api/address/all-address');

      debugPrint('[ADDRESS DATA SOURCE] Response received successfully');
      final responseData = response.data as Map<String, dynamic>;

      // Log full response for debugging
      debugPrint('[ADDRESS DATA SOURCE] Full response: $responseData');

      final addressesList = responseData['addresses'] as List?;
      if (addressesList != null) {
        final addresses = <AddressModel>[];
        for (var i = 0; i < addressesList.length; i++) {
          try {
            final json = addressesList[i] as Map<String, dynamic>;
            debugPrint('[ADDRESS DATA SOURCE] Parsing address $i: $json');
            final address = AddressModel.fromJson(json);
            addresses.add(address);
          } catch (e, stackTrace) {
            debugPrint('[ADDRESS DATA SOURCE] Error parsing address $i: $e');
            debugPrint('[ADDRESS DATA SOURCE] Stack trace: $stackTrace');
            debugPrint(
              '[ADDRESS DATA SOURCE] Address data: ${addressesList[i]}',
            );
            // Continue with other addresses instead of failing completely
          }
        }
        debugPrint(
          '[ADDRESS DATA SOURCE] Parsed ${addresses.length} addresses',
        );
        return addresses;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('[ADDRESS DATA SOURCE] Error occurred: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '[ADDRESS DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[ADDRESS DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint(
        '[ADDRESS DATA SOURCE] Extracted error message: $errorMessage',
      );
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('[ADDRESS DATA SOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> addAddress(Map<String, dynamic> body) async {
    debugPrint('[ADDRESS DATA SOURCE] Adding address with body: $body');

    try {
      final response = await dio.post('/api/address/add-address', data: body);

      debugPrint('[ADDRESS DATA SOURCE] Address added successfully');
      final responseData = response.data as Map<String, dynamic>?;

      // Check for error in response
      if (responseData != null && responseData.containsKey('error')) {
        throw Exception(
          responseData['error'] as String? ?? 'Failed to add address',
        );
      }
    } on DioException catch (e) {
      debugPrint('[ADDRESS DATA SOURCE] Error adding address: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '[ADDRESS DATA SOURCE] Error status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '[ADDRESS DATA SOURCE] Error response data: ${e.response?.data}',
        );
      }
      final errorMessage = _extractErrorMessage(e);
      debugPrint(
        '[ADDRESS DATA SOURCE] Extracted error message: $errorMessage',
      );
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint(
        '[ADDRESS DATA SOURCE] Unexpected error while adding address: $e',
      );
      rethrow;
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['error'] as String? ??
            data['message'] as String? ??
            'Failed to fetch address data';
      } else if (data is String) {
        return data;
      }
    }
    return e.message ?? 'Network error occurred';
  }
}
