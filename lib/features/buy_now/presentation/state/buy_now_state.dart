import 'package:equatable/equatable.dart';

enum BuyNowStep { details, otp }

class BuyNowState extends Equatable {
  final BuyNowStep step;
  
  // Product Information
  final String productType;
  final String productID;
  final String? variationID;
  final int quantity;
  final List<Map<String, dynamic>>? selectedItems;
  final Map<String, dynamic>? customInputs;
  final Map<String, dynamic>? selectedDressType;
  
  // Display info
  final String? productName;
  final String? productImage;
  final double salePrice;
  final double regularPrice;

  // Address
  final String? selectedAddressID;
  final Map<String, dynamic>? newAddressData;
  final bool isAddingNewAddress;
  
  // Pricing
  final double shippingFee;
  final String couponCode;
  final double couponDiscount;
  final double codHandlingFee;
  final double offerSavedAmount;
  final int freeUnits;
  final String paymentMode; // 'COD' or 'PREPAID'

  // Loading & Error states
  final bool isLoading;
  final bool isPlacingOrder;
  final bool isVerifyingOtp;
  final bool isCheckingPhone;
  final String? error;
  final String? couponError;
  final bool otpRequired;
  final bool phoneExists;

  // Guest Info
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String otpCode;

  const BuyNowState({
    this.step = BuyNowStep.details,
    required this.productType,
    required this.productID,
    this.variationID,
    required this.quantity,
    this.selectedItems,
    this.customInputs,
    this.selectedDressType,
    this.productName,
    this.productImage,
    required this.salePrice,
    required this.regularPrice,
    this.selectedAddressID,
    this.newAddressData,
    this.isAddingNewAddress = false,
    this.shippingFee = 0.0,
    this.couponCode = '',
    this.couponDiscount = 0.0,
    this.codHandlingFee = 0.0,
    this.offerSavedAmount = 0.0,
    this.freeUnits = 0,
    this.paymentMode = 'PREPAID',
    this.isLoading = false,
    this.isPlacingOrder = false,
    this.isVerifyingOtp = false,
    this.isCheckingPhone = false,
    this.error,
    this.couponError,
    this.otpRequired = false,
    this.phoneExists = false,
    this.guestName = '',
    this.guestEmail = '',
    this.guestPhone = '',
    this.otpCode = '',
  });

  double get subtotal => salePrice * quantity;
  double get grandTotal => (subtotal - offerSavedAmount - couponDiscount + shippingFee + (paymentMode == 'COD' ? 8.0 : 0.0));

  BuyNowState copyWith({
    BuyNowStep? step,
    String? productType,
    String? productID,
    String? variationID,
    int? quantity,
    List<Map<String, dynamic>>? selectedItems,
    Map<String, dynamic>? customInputs,
    Map<String, dynamic>? selectedDressType,
    String? productName,
    String? productImage,
    double? salePrice,
    double? regularPrice,
    String? selectedAddressID,
    Map<String, dynamic>? newAddressData,
    bool? isAddingNewAddress,
    double? shippingFee,
    String? couponCode,
    double? couponDiscount,
    double? codHandlingFee,
    double? offerSavedAmount,
    int? freeUnits,
    String? paymentMode,
    bool? isLoading,
    bool? isPlacingOrder,
    bool? isVerifyingOtp,
    bool? isCheckingPhone,
    String? error,
    String? couponError,
    bool? otpRequired,
    bool? phoneExists,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? otpCode,
  }) {
    return BuyNowState(
      step: step ?? this.step,
      productType: productType ?? this.productType,
      productID: productID ?? this.productID,
      variationID: variationID ?? this.variationID,
      quantity: quantity ?? this.quantity,
      selectedItems: selectedItems ?? this.selectedItems,
      customInputs: customInputs ?? this.customInputs,
      selectedDressType: selectedDressType ?? this.selectedDressType,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      salePrice: salePrice ?? this.salePrice,
      regularPrice: regularPrice ?? this.regularPrice,
      selectedAddressID: selectedAddressID ?? this.selectedAddressID,
      newAddressData: newAddressData ?? this.newAddressData,
      isAddingNewAddress: isAddingNewAddress ?? this.isAddingNewAddress,
      shippingFee: shippingFee ?? this.shippingFee,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      codHandlingFee: codHandlingFee ?? this.codHandlingFee,
      offerSavedAmount: offerSavedAmount ?? this.offerSavedAmount,
      freeUnits: freeUnits ?? this.freeUnits,
      paymentMode: paymentMode ?? this.paymentMode,
      isLoading: isLoading ?? this.isLoading,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isCheckingPhone: isCheckingPhone ?? this.isCheckingPhone,
      error: error,
      couponError: couponError,
      otpRequired: otpRequired ?? this.otpRequired,
      phoneExists: phoneExists ?? this.phoneExists,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      otpCode: otpCode ?? this.otpCode,
    );
  }

  @override
  List<Object?> get props => [
        step,
        productType,
        productID,
        variationID,
        quantity,
        selectedItems,
        customInputs,
        selectedDressType,
        productName,
        productImage,
        salePrice,
        regularPrice,
        selectedAddressID,
        newAddressData,
        isAddingNewAddress,
        shippingFee,
        couponCode,
        couponDiscount,
        codHandlingFee,
        offerSavedAmount,
        freeUnits,
        paymentMode,
        isLoading,
        isPlacingOrder,
        isVerifyingOtp,
        isCheckingPhone,
        error,
        couponError,
        otpRequired,
        phoneExists,
        guestName,
        guestEmail,
        guestPhone,
        otpCode,
      ];
}
