import '../../../../features/order/domain/entities/combo_item.dart';

/// Cart item entity
///
/// Supports product hierarchy matching Order Detail Page:
/// - Variable products: single item with variationValues
/// - Combo/Make Combo: parent item with nested comboItems
/// - Custom products: single item with customInputs
class CartItem {
  final String cartItemID;
  final String productID;
  final int quantity;
  final String name;
  final double? regularPrice;
  final double? salePrice;
  final String? variationID;
  final String? variationName;
  final double? unitPriceBefore;
  final double? unitPriceAfter;
  final double? lineTotalBefore;
  final double? lineTotalAfter;
  final bool offerApplied;
  final String offerStatus; // 'none' | 'applied' | 'expired' | 'missing'
  final int selected; // 0 or 1
  final int isFlashSale; // 0 or 1
  final String? comboID;
  final String?
      productType; // 'simple', 'variable', 'custom', 'combo', 'make_combo', 'customproduct'
  final bool isAvailable;
  final String? stockStatus; // 'in_stock', 'out_of_stock', 'low_stock'
  final int? variationStock;

  // Hierarchy support fields (matching OrderItemEntity structure)
  final String? imageUrl;
  final String? brand;
  final List<Map<String, dynamic>>?
  variationValues; // For variable products (key-value pairs)
  final List<ComboItemEntity>?
  comboItems; // For combo/make_combo products (nested children)
  final Map<String, dynamic>?
  customInputs; // For custom products (user-provided data)

  const CartItem({
    required this.cartItemID,
    required this.productID,
    required this.quantity,
    required this.name,
    this.regularPrice,
    this.salePrice,
    this.variationID,
    this.variationName,
    this.unitPriceBefore,
    this.unitPriceAfter,
    this.lineTotalBefore,
    this.lineTotalAfter,
    this.offerApplied = false,
    this.offerStatus = 'none',
    this.selected = 0,
    this.isFlashSale = 0,
    this.comboID,
    this.productType,
    this.isAvailable = true,
    this.stockStatus = 'in_stock',
    this.variationStock,
    this.imageUrl,
    this.brand,
    this.variationValues,
    this.comboItems,
    this.customInputs,
  });

  CartItem copyWith({
    String? cartItemID,
    String? productID,
    int? quantity,
    String? name,
    double? regularPrice,
    double? salePrice,
    String? variationID,
    String? variationName,
    double? unitPriceBefore,
    double? unitPriceAfter,
    double? lineTotalBefore,
    double? lineTotalAfter,
    bool? offerApplied,
    String? offerStatus,
    int? selected,
    int? isFlashSale,
    String? comboID,
    String? productType,
    bool? isAvailable,
    String? stockStatus,
    int? variationStock,
    String? imageUrl,
    String? brand,
    List<Map<String, dynamic>>? variationValues,
    List<ComboItemEntity>? comboItems,
    Map<String, dynamic>? customInputs,
  }) {
    return CartItem(
      cartItemID: cartItemID ?? this.cartItemID,
      productID: productID ?? this.productID,
      quantity: quantity ?? this.quantity,
      name: name ?? this.name,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      variationID: variationID ?? this.variationID,
      variationName: variationName ?? this.variationName,
      unitPriceBefore: unitPriceBefore ?? this.unitPriceBefore,
      unitPriceAfter: unitPriceAfter ?? this.unitPriceAfter,
      lineTotalBefore: lineTotalBefore ?? this.lineTotalBefore,
      lineTotalAfter: lineTotalAfter ?? this.lineTotalAfter,
      offerApplied: offerApplied ?? this.offerApplied,
      offerStatus: offerStatus ?? this.offerStatus,
      selected: selected ?? this.selected,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      comboID: comboID ?? this.comboID,
      productType: productType ?? this.productType,
      isAvailable: isAvailable ?? this.isAvailable,
      stockStatus: stockStatus ?? this.stockStatus,
      variationStock: variationStock ?? this.variationStock,
      imageUrl: imageUrl ?? this.imageUrl,
      brand: brand ?? this.brand,
      variationValues: variationValues ?? this.variationValues,
      comboItems: comboItems ?? this.comboItems,
      customInputs: customInputs ?? this.customInputs,
    );
  }

  bool get isSelected => selected == 1;
}
