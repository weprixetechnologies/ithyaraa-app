import 'package:dio/dio.dart';
import '../../../combo/data/models/combo_detail_model.dart';

/// Remote data source for Make Combo detail API
/// GET /api/make-combo/detail-user/{productID}
abstract class MakeComboDetailRemoteDataSource {
  Future<ComboDetailModel> getMakeComboDetail(String productID);
}

class MakeComboDetailRemoteDataSourceImpl
    implements MakeComboDetailRemoteDataSource {
  final Dio dio;

  MakeComboDetailRemoteDataSourceImpl({required this.dio});

  @override
  Future<ComboDetailModel> getMakeComboDetail(String productID) async {
    if (productID.isEmpty) {
      throw Exception('Invalid product ID: Product ID cannot be empty.');
    }

    try {
      final endpoint = '/api/make-combo/detail-user/$productID';
      final response = await dio.get(endpoint);

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final comboData = responseData['data'] as Map<String, dynamic>?;
        if (comboData == null) {
          throw Exception('Make combo data not found in API response');
        }
        return ComboDetailModel.fromJson(comboData);
      } else {
        throw Exception('Invalid response format from make combo detail API');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) return message;
        final error = data['error'] as String?;
        if (error != null && error.isNotEmpty) return error;
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid product ID.';
        case 404:
          return 'Make combo not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed with status $statusCode';
      }
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
