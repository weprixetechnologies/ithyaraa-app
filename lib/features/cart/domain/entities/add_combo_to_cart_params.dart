/// Parameters for adding combo product to cart
class AddComboToCartParams {
  final String mainProductID;
  final int quantity;
  final List<Map<String, String>> products; // [{productID, variationID}]

  const AddComboToCartParams({
    required this.mainProductID,
    required this.quantity,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      'mainProductID': mainProductID,
      'quantity': quantity,
      'products': products,
    };
  }
}
