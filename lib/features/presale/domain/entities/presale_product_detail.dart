import '../../../product_detail/variable/domain/entities/product_detail.dart';

/// Presale Product Detail entity extending standard Product Detail
class PresaleProductDetailEntity extends ProductDetailEntity {
  final DateTime? preSaleStartDate;
  final DateTime? preSaleEndDate;
  final DateTime? expectedDeliveryDate;
  final String? sizeChartUrl;

  const PresaleProductDetailEntity({
    required super.productID,
    required super.productName,
    super.brand,
    super.description,
    super.regularPrice,
    super.salePrice,
    super.overridePrice,
    super.discountPercentage,
    super.rating,
    super.reviewCount,
    super.inStock = true,
    super.stockQuantity = 0,
    required super.featuredImages,
    required super.galleryImages,
    required super.productAttributes,
    required super.variations,
    required super.crossSellProducts,
    super.tab1,
    super.tab2,
    super.offer,
    super.isFlashSale = false,
    super.flashSaleEndTime,
    this.preSaleStartDate,
    this.preSaleEndDate,
    this.expectedDeliveryDate,
    this.sizeChartUrl,
  });

  bool get isUpcoming {
    final now = DateTime.now();
    return preSaleStartDate != null && preSaleStartDate!.isAfter(now);
  }

  bool get isActive {
    final now = DateTime.now();
    if (preSaleStartDate == null || preSaleEndDate == null) return false;
    return now.isAfter(preSaleStartDate!) && now.isBefore(preSaleEndDate!);
  }
}
