import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/homepage_section_model.dart';

/// Remote data source for homepage sections API
abstract class HomepageSectionRemoteDataSource {
  Future<List<HomepageSectionModel>> getActiveSections();
}

class HomepageSectionRemoteDataSourceImpl
    implements HomepageSectionRemoteDataSource {
  final Dio dio;

  HomepageSectionRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HomepageSectionModel>> getActiveSections() async {
    try {
      final response = await dio.get('/api/homepage-sections/active');

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('[HOMEPAGE SECTIONS] Response data: $responseData');

      final data = responseData['data'] as List? ?? [];
      debugPrint('[HOMEPAGE SECTIONS] Parsed ${data.length} sections');

      final sections = data.map((item) {
        debugPrint('[HOMEPAGE SECTIONS] Parsing item: $item');
        return HomepageSectionModel.fromJson(item as Map<String, dynamic>);
      }).toList();

      debugPrint(
        '[HOMEPAGE SECTIONS] Successfully parsed ${sections.length} sections',
      );
      return sections;
    } on DioException catch (e) {
      debugPrint('[HOMEPAGE SECTIONS] DioException: ${e.message}');
      debugPrint('[HOMEPAGE SECTIONS] Response: ${e.response?.data}');
      throw Exception(
        e.response?.data?['message'] as String? ??
            'Failed to fetch homepage sections',
      );
    } catch (e, stackTrace) {
      debugPrint('[HOMEPAGE SECTIONS] Unexpected error: $e');
      debugPrint('[HOMEPAGE SECTIONS] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
