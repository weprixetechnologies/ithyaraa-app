import 'package:equatable/equatable.dart';

class SectionItem extends Equatable {
  final int id;
  final String type;
  final int orderIndex;
  final ProductGroup? group;
  final ImageSection? section;
  final FeaturedCoupon? coupon;
  final List<ProductItem> products;
  final List<ImageItem> images;

  const SectionItem({
    required this.id,
    required this.type,
    required this.orderIndex,
    this.group,
    this.section,
    this.coupon,
    this.products = const [],
    this.images = const [],
  });

  factory SectionItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final type = json['type'] as String? ?? '';
    return SectionItem(
      id: parseInt(json['id']),
      type: type,
      orderIndex: parseInt(json['orderIndex']),
      group: type == 'productsection' && json['group'] != null
          ? ProductGroup.fromJson(json['group'] as Map<String, dynamic>)
          : null,
      section: type == 'imagesection' && json['section'] != null
          ? ImageSection.fromJson(json['section'] as Map<String, dynamic>)
          : null,
      coupon: type == 'featuredcoupon' && json['coupon'] != null
          ? FeaturedCoupon.fromJson(json['coupon'] as Map<String, dynamic>)
          : null,
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ImageItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, type, orderIndex, group, section, coupon, products, images];
}

class ProductGroup extends Equatable {
  final int id;
  final int sectionID;
  final String title;
  final int orderIndex;
  final String? imageUrl;

  const ProductGroup({
    required this.id,
    required this.sectionID,
    required this.title,
    required this.orderIndex,
    this.imageUrl,
  });

  factory ProductGroup.fromJson(Map<String, dynamic> json) {
    return ProductGroup(
      id: json['id'] as int,
      sectionID: json['sectionID'] as int,
      title: json['title'] as String? ?? '',
      orderIndex: json['orderIndex'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, sectionID, title, orderIndex, imageUrl];
}

class ProductItem extends Equatable {
  final String productID;
  final int position;
  final String name;
  final String? type; // 'variable', 'custom', 'makecombo', 'combo'
  final String? regularPrice;
  final String? salePrice;
  final double? rating;
  final int? reviewCount;
  final List<ProductImage> featuredImage;

  const ProductItem({
    required this.productID,
    required this.position,
    required this.name,
    this.type,
    this.regularPrice,
    this.salePrice,
    this.rating,
    this.reviewCount,
    this.featuredImage = const [],
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      productID: json['productID']?.toString() ?? '',
      position: json['position'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      regularPrice: json['regularPrice']?.toString(),
      salePrice: json['salePrice']?.toString(),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] as int?,
      featuredImage: (json['featuredImage'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props =>
      [productID, position, name, type, regularPrice, salePrice, rating, reviewCount, featuredImage];
}

class ProductImage extends Equatable {
  final String imgUrl;
  final String? imgAlt;

  const ProductImage({required this.imgUrl, this.imgAlt});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imgUrl: json['imgUrl'] as String? ?? '',
      imgAlt: json['imgAlt'] as String?,
    );
  }

  @override
  List<Object?> get props => [imgUrl, imgAlt];
}

class ImageSection extends Equatable {
  final int id;
  final String sectionID;
  final String title;
  final String? imageUrl;
  final String? layoutID;

  const ImageSection({
    required this.id,
    required this.sectionID,
    required this.title,
    this.imageUrl,
    this.layoutID,
  });

  factory ImageSection.fromJson(Map<String, dynamic> json) {
    return ImageSection(
      id: json['id'] as int,
      sectionID: json['sectionID']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      layoutID: json['layoutID']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, sectionID, title, imageUrl, layoutID];
}

class ImageItem extends Equatable {
  final int id;
  final int position;
  final String imageUrl;
  final Map<String, dynamic>? filters;

  const ImageItem({
    required this.id,
    required this.position,
    required this.imageUrl,
    this.filters,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id: json['id'] as int,
      position: json['position'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      filters: json['filters'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, position, imageUrl, filters];
}

class HomeCategory extends Equatable {
  final int categoryID;
  final String imageUrl;
  final String categoryName;

  const HomeCategory({
    required this.categoryID,
    required this.imageUrl,
    required this.categoryName,
  });

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    return HomeCategory(
      categoryID: json['categoryID'] as int,
      imageUrl: json['imageUrl'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [categoryID, imageUrl, categoryName];
}

class ReelModel extends Equatable {
  final int id;
  final String videoUrl;
  final String? thumbnailUrl;

  const ReelModel({
    required this.id,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] as int,
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, videoUrl, thumbnailUrl];
}

class FeaturedCoupon extends Equatable {
  final int id;
  final String popupImage;
  final String iconImage;
  final String? couponCode;
  final bool isActive;

  const FeaturedCoupon({
    required this.id,
    required this.popupImage,
    required this.iconImage,
    this.couponCode,
    required this.isActive,
  });

  factory FeaturedCoupon.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return FeaturedCoupon(
      id: parseInt(json['id']),
      popupImage: json['popupImage'] as String? ?? '',
      iconImage: json['iconImage'] as String? ?? '',
      couponCode: json['couponCode'] as String?,
      isActive: json['isActive'] == true || json['isActive'] == 1 || json['isActive'] == '1',
    );
  }

  @override
  List<Object?> get props => [id, popupImage, iconImage, couponCode, isActive];
}

