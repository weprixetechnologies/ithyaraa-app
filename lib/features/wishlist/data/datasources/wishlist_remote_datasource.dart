import 'package:dio/dio.dart';
import '../models/wishlist_model.dart';
import 'package:flutter/foundation.dart';

abstract class WishlistRemoteDataSource {
  Future<WishlistModel> getWishlist();
  Future<WishlistModel> addWishlist(String productID);
  Future<WishlistModel> removeWishlist(String wishlistItemID);
  Future<WishlistModel> removeProductFromWishlist(String productID);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final Dio dio;

  WishlistRemoteDataSourceImpl({required this.dio});

  @override
  Future<WishlistModel> getWishlist() async {
    try {
      debugPrint(
        '[WishlistRemoteDataSource] REQUEST → GET /api/wishlist/get-wishlist',
      );
      final response = await dio.get('/api/wishlist/get-wishlist');
      debugPrint(
        '[WishlistRemoteDataSource] RESPONSE ← GET /api/wishlist/get-wishlist '
        'status: ${response.statusCode}, data: ${response.data}',
      );
      return WishlistModel.fromJson(response.data);
    } catch (e) {
      debugPrint(
        '[WishlistRemoteDataSource] ERROR ← GET /api/wishlist/get-wishlist: $e',
      );
      rethrow;
    }
  }

  @override
  Future<WishlistModel> addWishlist(String productID) async {
    // Validate productID before making API call
    final trimmedProductID = productID.trim();

    if (trimmedProductID.isEmpty ||
        trimmedProductID == 'undefined' ||
        trimmedProductID == 'null') {
      throw Exception(
        'Invalid product ID: "$productID". Product ID must be a valid alphanumeric string.',
      );
    }

    // Log the productID being sent to API
    debugPrint(
      '[WishlistRemoteDataSource] Adding to wishlist - ProductID: "$trimmedProductID"',
    );

    try {
      final response = await dio.post(
        '/api/wishlist/add-wishlist',
        data: {'productID': trimmedProductID},
      );
      // Assuming API returns the updated wishlist or the added item.
      // If it returns just the added item, we might need to re-fetch or assume it's part of the list.
      // For now, let's assume it returns the updated wishlist wrapper or consistent structure.
      // If it only returns the added item, logic in Repository must handle it.
      // Let's assume standard behavior: returns updated list or we fetch again.
      // BUT requirement says: "Minimal API calls". So ideally API returns updated state.
      // If the API docs are strict: "POST /add-wishlist", likely returns the added item or success.
      // For safety in "Minimal API calls", we usually rely on local Optimistic update,
      // but if we want the SOURCE OF TRUTH from API, we hope it returns the list.
      // If it doesn't, we might rely on the local optimistic state if success.
      // Let's stick to parsing `response.data` as WishlistModel for now, or adapt later.
      return WishlistModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WishlistModel> removeWishlist(String wishlistItemID) async {
    try {
      final response = await dio.delete('/api/wishlist/remove/$wishlistItemID');
      return WishlistModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WishlistModel> removeProductFromWishlist(String productID) async {
    try {
      final response = await dio.delete(
        '/api/wishlist/remove-product/$productID',
      );
      return WishlistModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
