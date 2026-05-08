import '../../domain/entities/wishlist.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WishlistEntity> getWishlist() async {
    return await remoteDataSource.getWishlist();
  }

  @override
  Future<WishlistEntity> addWishlist(String productID) async {
    // First call the API to add the item
    await remoteDataSource.addWishlist(productID);
    // Then fetch the latest wishlist so state stays in sync with server
    return await remoteDataSource.getWishlist();
  }

  @override
  Future<WishlistEntity> removeWishlist(String wishlistItemID) async {
    return await remoteDataSource.removeWishlist(wishlistItemID);
  }

  @override
  Future<WishlistEntity> removeProductFromWishlist(String productID) async {
    return await remoteDataSource.removeProductFromWishlist(productID);
  }
}
