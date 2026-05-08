/// Combo item entity representing a lightweight product snapshot in a combo
/// 
/// Combo sub-items are NOT full order items - they don't have:
/// - quantity, pricing, totals, tracking info
/// They are lightweight product references with:
/// - productID, name, image, brand, variation info
class ComboItemEntity {
  final String productID;
  final String name;
  final String? imageUrl; // First image from featuredImage array
  final List<Map<String, dynamic>>? featuredImages;
  final String? brand;
  final String? variationName; // API uses "variationName", not "storedVariationName"
  final String? variationID;
  final List<Map<String, dynamic>>? variationValues;

  const ComboItemEntity({
    required this.productID,
    required this.name,
    this.imageUrl,
    this.featuredImages,
    this.brand,
    this.variationName,
    this.variationID,
    this.variationValues,
  });
}
