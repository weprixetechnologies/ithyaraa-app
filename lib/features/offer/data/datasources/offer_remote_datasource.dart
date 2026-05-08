import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/offer_response_model.dart';
import '../../domain/entities/offer_filters.dart';

OfferResponseModel _parseOfferResponse(Map<String, dynamic> data) {
  return OfferResponseModel.fromJson(data);
}

/// Remote data source for offer API
abstract class OfferRemoteDataSource {
  Future<OfferResponseModel> getAllOffers({
    int page = 1,
    int limit = 10,
    OfferFilters? filters,
  });
}

class OfferRemoteDataSourceImpl implements OfferRemoteDataSource {
  final Dio dio;

  OfferRemoteDataSourceImpl({required this.dio});

  @override
  Future<OfferResponseModel> getAllOffers({
    int page = 1,
    int limit = 10,
    OfferFilters? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (filters != null) {
        if (filters.offerID != null && filters.offerID!.isNotEmpty) {
          queryParams['offerID'] = filters.offerID;
        }
        if (filters.offerName != null && filters.offerName!.isNotEmpty) {
          queryParams['offerName'] = filters.offerName;
        }
        if (filters.offerType != null && filters.offerType!.isNotEmpty) {
          queryParams['offerType'] = filters.offerType;
        }
        if (filters.buyAt != null) {
          queryParams['buyAt'] = filters.buyAt;
        }
        if (filters.buyCount != null) {
          queryParams['buyCount'] = filters.buyCount;
        }
        if (filters.getCount != null) {
          queryParams['getCount'] = filters.getCount;
        }
      }

      final response = await dio.get(
        '/api/offer/public-list',
        queryParameters: queryParams,
      );

      return await compute(_parseOfferResponse, response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] as String? ?? 'Failed to fetch offers',
      );
    }
  }
}
