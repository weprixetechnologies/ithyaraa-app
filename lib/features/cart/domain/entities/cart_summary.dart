/// Cart summary entity
class CartSummary {
  final double subtotal;
  final double total;
  final double totalDiscount;
  final double shipping;
  final bool anyModifications;

  const CartSummary({
    required this.subtotal,
    required this.total,
    required this.totalDiscount,
    this.shipping = 0,
    this.anyModifications = false,
  });

  CartSummary copyWith({
    double? subtotal,
    double? total,
    double? totalDiscount,
    double? shipping,
    bool? anyModifications,
  }) {
    return CartSummary(
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      shipping: shipping ?? this.shipping,
      anyModifications: anyModifications ?? this.anyModifications,
    );
  }
}
