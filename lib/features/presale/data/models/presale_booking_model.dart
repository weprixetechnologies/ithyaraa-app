import '../../domain/entities/presale_booking.dart';

class PresaleBookingModel extends PresaleBookingEntity {
  PresaleBookingModel({
    required super.preBookingID,
    required super.uid,
    super.paymentMode,
    required super.paymentStatus,
    required super.orderStatus,
    required super.status,
    required super.subtotal,
    required super.totalDiscount,
    required super.total,
    required super.createdAt,
    super.itemCount = 0,
    super.items,
    super.deliveryAddress,
  });

  factory PresaleBookingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return PresaleBookingModel(
      preBookingID: json['preBookingID']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      paymentMode: json['paymentMode']?.toString(),
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      orderStatus: json['orderStatus']?.toString() ?? 'pending',
      status: json['status']?.toString() ?? 'pending',
      subtotal: parseDouble(json['subtotal']),
      totalDiscount: parseDouble(json['totalDiscount']),
      total: parseDouble(json['total']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      itemCount: parseInt(json['itemCount']),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => PresaleBookingItemModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
      deliveryAddress: json['deliveryAddress'] != null
          ? PresaleAddressModel.fromJson(json['deliveryAddress'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PresaleBookingItemModel extends PresaleBookingItemEntity {
  PresaleBookingItemModel({
    required super.productID,
    required super.name,
    required super.quantity,
    super.variationID,
    super.variationName,
    required super.salePrice,
    required super.regularPrice,
    required super.lineTotalBefore,
    required super.lineTotalAfter,
    required super.featuredImage,
  });

  factory PresaleBookingItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // featuredImage in backend can be JSON string or array of objects/strings
    List<String> images = [];
    final rawImg = json['featuredImage'];
    if (rawImg is List) {
      for (var item in rawImg) {
        if (item is Map && item.containsKey('imgUrl')) {
          images.add(item['imgUrl'].toString());
        } else if (item != null) {
          images.add(item.toString());
        }
      }
    } else if (rawImg is String && rawImg.isNotEmpty) {
      images = [rawImg];
    } else if (rawImg is Map && rawImg.containsKey('imgUrl')) {
      images = [rawImg['imgUrl'].toString()];
    }

    return PresaleBookingItemModel(
      productID: json['productID']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: parseInt(json['quantity']),
      variationID: json['variationID']?.toString(),
      variationName: json['variationName']?.toString() ?? json['storedVariationName']?.toString(),
      salePrice: parseDouble(json['salePrice']),
      regularPrice: parseDouble(json['regularPrice']),
      lineTotalBefore: parseDouble(json['lineTotalBefore']),
      lineTotalAfter: parseDouble(json['lineTotalAfter']),
      featuredImage: images,
    );
  }
}

class PresaleAddressModel extends PresaleAddressEntity {
  PresaleAddressModel({
    required super.line1,
    super.line2,
    required super.city,
    required super.state,
    required super.pincode,
    super.landmark,
    super.phoneNumber,
  });

  factory PresaleAddressModel.fromJson(Map<String, dynamic> json) {
    return PresaleAddressModel(
      line1: json['line1']?.toString() ?? '',
      line2: json['line2']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
    );
  }
}
