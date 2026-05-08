import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/homepage_section_remote_datasource.dart';
import '../../data/models/homepage_section_model.dart';

/// Provider for Dio instance for homepage sections API (public endpoint, no auth required)
final homepageSectionDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://backend.ithyaraa.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add logging interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[DIO] REQUEST → ${options.method} ${options.path}');
        if (options.queryParameters.isNotEmpty) {
          debugPrint('[DIO] Query Parameters: ${options.queryParameters}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '[DIO] RESPONSE → ${response.requestOptions.path} (${response.statusCode})',
        );
        if (response.data != null) {
          debugPrint('[DIO] Response Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('[DIO] ERROR → ${error.requestOptions.path}');
        debugPrint('[DIO] Error: ${error.message}');
        if (error.response != null) {
          debugPrint('[DIO] Error Status: ${error.response?.statusCode}');
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

/// Provider for homepage section remote data source
final homepageSectionRemoteDataSourceProvider =
    Provider<HomepageSectionRemoteDataSource>((ref) {
      final dio = ref.read(homepageSectionDioProvider);
      return HomepageSectionRemoteDataSourceImpl(dio: dio);
    });

/// Provider for active homepage sections
/// Returns empty list on error (fails silently)
final activeHomepageSectionsProvider = FutureProvider<List<HomepageSectionModel>>((
  ref,
) async {
  try {
    debugPrint('[HOMEPAGE SECTIONS PROVIDER] Fetching sections...');
    final dataSource = ref.read(homepageSectionRemoteDataSourceProvider);
    final sections = await dataSource.getActiveSections();
    debugPrint(
      '[HOMEPAGE SECTIONS PROVIDER] Successfully fetched ${sections.length} sections',
    );
    return sections;
  } catch (e, stackTrace) {
    debugPrint('[HOMEPAGE SECTIONS PROVIDER] Error fetching sections: $e');
    debugPrint('[HOMEPAGE SECTIONS PROVIDER] Stack trace: $stackTrace');
    // Fail silently - return empty list
    return [];
  }
});
