import '../entities/wishlist.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase {
  final WishlistRepository repository;

  GetWishlistUseCase(this.repository);

  Future<WishlistEntity> call() async {
    return await repository.getWishlist();
  }
}

class AddWishlistUseCase {
  final WishlistRepository repository;

  AddWishlistUseCase(this.repository);

  Future<WishlistEntity> call(String productID) async {
    return await repository.addWishlist(productID);
  }
}

class RemoveWishlistUseCase {
  final WishlistRepository repository;

  RemoveWishlistUseCase(this.repository);

  Future<WishlistEntity> call(String wishlistItemID) async {
    return await repository.removeWishlist(wishlistItemID);
  }
}

class RemoveProductFromWishlistUseCase {
  final WishlistRepository repository;

  RemoveProductFromWishlistUseCase(this.repository);

  Future<WishlistEntity> call(String productID) async {
    return await repository.removeProductFromWishlist(productID);
  }
}
