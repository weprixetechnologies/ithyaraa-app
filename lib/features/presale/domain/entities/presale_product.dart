import '../../../shop/domain/entities/product.dart';

/// Presale Product entity extending standard Product
class PresaleProductEntity extends ProductEntity {
  final DateTime? preSaleStartDate;
  final DateTime? preSaleEndDate;
  final DateTime? expectedDeliveryDate;

  const PresaleProductEntity({
    required super.productID,
    required super.productName,
    super.description,
    super.brand,
    super.type,
    super.regularPrice,
    super.salePrice,
    super.discountPercentage,
    super.rating,
    super.reviewCount,
    required super.featuredImages,
    required super.categories,
    super.inStock,
    super.createdAt,
    super.isFlashSale,
    super.flashSaleEndTime,
    super.flashSalePrice,
    this.preSaleStartDate,
    this.preSaleEndDate,
    this.expectedDeliveryDate,
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
