/// Shop filters entity for configuring shop page
class ShopFilters {
  final List<int>? categoryIDs;
  final List<int>? brandIDs;
  final String? search;
  final String? sortBy;
  final String? sortOrder;
  final double? minPrice;
  final double? maxPrice;
  final String? stock; // 'in' or 'out' (API expects string)
  final String? priceBands; // Comma-separated: 'u500', '500-999', '1000-1999', '2000+'
  final String? sectionid; // Comma-separated string (API expects string)
  final String? type; // 'variable', 'all', etc.
  final String? offerID;

  const ShopFilters({
    this.categoryIDs,
    this.brandIDs,
    this.search,
    this.sortBy,
    this.sortOrder,
    this.minPrice,
    this.maxPrice,
    this.stock,
    this.priceBands,
    this.sectionid,
    this.type,
    this.offerID,
  });

  ShopFilters copyWith({
    List<int>? categoryIDs,
    List<int>? brandIDs,
    String? search,
    String? sortBy,
    String? sortOrder,
    double? minPrice,
    double? maxPrice,
    String? stock,
    String? priceBands,
    String? sectionid,
    String? type,
    String? offerID,
  }) {
    return ShopFilters(
      categoryIDs: categoryIDs ?? this.categoryIDs,
      brandIDs: brandIDs ?? this.brandIDs,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      stock: stock ?? this.stock,
      priceBands: priceBands ?? this.priceBands,
      sectionid: sectionid ?? this.sectionid,
      type: type ?? this.type,
      offerID: offerID ?? this.offerID,
    );
  }
}
