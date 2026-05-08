import 'package:dio/dio.dart';
import 'models/section_models.dart';

class SectionService {
  SectionService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;
  final _endpoint = 'https://backend.ithyaraa.com/api/section-items';

  Future<List<SectionItem>> fetchSectionItems() async {
    final resp = await _dio.get(_endpoint);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      return [];
    }

    final data = resp.data;
    if (data == null || data['data'] == null) return [];

    final list = (data['data'] as List<dynamic>)
        .map((e) => SectionItem.fromJson(e as Map<String, dynamic>))
        .toList();

    list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return list;
  }

  Future<List<HomeCategory>> fetchHomeCategories() async {
    final resp = await _dio.get(
      'https://backend.ithyaraa.com/api/home-categories',
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) return [];

    final data = resp.data;
    if (data == null) return [];

    return (data as List<dynamic>)
        .map((e) => HomeCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HomeCategory>> fetchCustomTabbedCategories() async {
    final resp = await _dio.get(
      'https://backend.ithyaraa.com/api/products/shop/customtabbed',
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) return [];

    final data = resp.data;
    if (data == null) return [];

    return (data as List<dynamic>)
        .map((e) => HomeCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReelModel>> fetchReels() async {
    try {
      final resp = await _dio.get(
        'https://backend.ithyaraa.com/api/reels/active',
      );
      if (resp.statusCode != 200 && resp.statusCode != 201) return [];

      final data = resp.data;
      if (data == null || data['success'] != true || data['data'] == null)
        return [];

      return (data['data'] as List<dynamic>)
          .map((e) => ReelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
