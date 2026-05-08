import 'package:equatable/equatable.dart';
import '../../../shop/domain/entities/product.dart';

/// Wishlist entity representing the user's wishlist
class WishlistEntity extends Equatable {
  final List<WishlistItemEntity> items;

  const WishlistEntity({required this.items});

  @override
  List<Object?> get props => [items];
}

class WishlistItemEntity extends Equatable {
  final String id;
  final ProductEntity product;

  const WishlistItemEntity({required this.id, required this.product});

  @override
  List<Object?> get props => [id, product];
}

