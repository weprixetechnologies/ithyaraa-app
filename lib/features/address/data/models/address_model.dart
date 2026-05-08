import '../../domain/entities/address.dart';

/// Address model for JSON serialization
class AddressModel extends Address {
  AddressModel({
    required super.addressID,
    required super.uid,
    required super.emailID,
    required super.line1,
    required super.line2,
    required super.pincode,
    super.city,
    required super.state,
    required super.landmark,
    required super.type,
    required super.phonenumber,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressID: (json['addressID'] as String?) ?? '',
      uid: (json['uid'] as String?) ?? '',
      emailID: (json['emailID'] as String?) ?? '',
      line1: (json['line1'] as String?) ?? '',
      line2: (json['line2'] as String?) ?? '',
      pincode: (json['pincode'] as String?) ?? '',
      city: json['city'] as String?,
      state: (json['state'] as String?) ?? '',
      landmark: (json['landmark'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'home',
      phonenumber: (json['phonenumber'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressID': addressID,
      'uid': uid,
      'emailID': emailID,
      'line1': line1,
      'line2': line2,
      'pincode': pincode,
      if (city != null) 'city': city,
      'state': state,
      'landmark': landmark,
      'type': type,
      'phonenumber': phonenumber,
    };
  }
}
