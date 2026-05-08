/// Parameters for adding item to cart
class AddToCartParams {
  final String productID;
  final int quantity;
  final String? variationID;
  final String? variationName;
  final String? referBy;
  final Map<String, dynamic>? customInputs;
  final Map<String, dynamic>? selectedDressType;

  const AddToCartParams({
    required this.productID,
    required this.quantity,
    this.variationID,
    this.variationName,
    this.referBy,
    this.customInputs,
    this.selectedDressType,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'productID': productID,
      'quantity': quantity,
    };
    if (variationID != null) json['variationID'] = variationID;
    if (variationName != null) json['variationName'] = variationName;
    if (referBy != null) json['referBy'] = referBy;
    if (customInputs != null) json['customInputs'] = customInputs;
    if (selectedDressType != null) json['selectedDressType'] = selectedDressType;
    return json;
  }
}
