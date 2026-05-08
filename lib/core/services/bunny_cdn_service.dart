import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// Bunny CDN upload service
///
/// Handles direct uploads to Bunny CDN storage
class BunnyCdnService {
  static const String storageZone = 'ithyaraa';
  static const String storageRegion = 'sg.storage.bunnycdn.com';
  static const String pullZoneUrl = 'https://ithyaraa.b-cdn.net';
  static const String accessKey = '7017f7c4-638b-48ab-add3858172a8-f520-4b88';

  final Dio dio;

  BunnyCdnService({Dio? dio}) : dio = dio ?? Dio();

  /// Upload image file to Bunny CDN
  ///
  /// Returns the public URL of the uploaded image
  Future<String> uploadImage(File imageFile) async {
    try {
      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'profile_${timestamp}$extension';
      final encodedFileName = Uri.encodeComponent(fileName);

      // Construct upload URL
      final uploadUrl = 'https://$storageRegion/$storageZone/$encodedFileName';

      // Read file bytes
      final fileBytes = await imageFile.readAsBytes();

      // Determine content type
      final contentType = _getContentType(extension);

      debugPrint('[BUNNY CDN] Uploading image: $fileName');
      debugPrint('[BUNNY CDN] Upload URL: $uploadUrl');
      debugPrint('[BUNNY CDN] File size: ${fileBytes.length} bytes');

      // Upload file
      final response = await dio.put(
        uploadUrl,
        data: fileBytes,
        options: Options(
          headers: {'AccessKey': accessKey, 'Content-Type': contentType},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Construct public URL
        final publicUrl = '$pullZoneUrl/$fileName';
        debugPrint('[BUNNY CDN] Upload successful: $publicUrl');
        return publicUrl;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('[BUNNY CDN] Upload error: ${e.message}');
      if (e.response != null) {
        debugPrint('[BUNNY CDN] Error response: ${e.response?.data}');
        throw Exception(
          e.response?.data['Message'] as String? ??
              e.response?.data['message'] as String? ??
              'Failed to upload image',
        );
      }
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      debugPrint('[BUNNY CDN] Unexpected error: $e');
      rethrow;
    }
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
