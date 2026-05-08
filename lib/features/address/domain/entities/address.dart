/// Address entity
class Address {
  final String addressID;
  final String uid;
  final String emailID;
  final String line1;
  final String line2;
  final String pincode;
  final String? city;
  final String state;
  final String landmark;
  final String type; // "home", "work", etc.
  final String phonenumber;

  const Address({
    required this.addressID,
    required this.uid,
    required this.emailID,
    required this.line1,
    required this.line2,
    required this.pincode,
    this.city,
    required this.state,
    required this.landmark,
    required this.type,
    required this.phonenumber,
  });

  /// Get full address as formatted string
  String get fullAddress {
    final parts = <String>[
      line1,
      line2,
      if (landmark.isNotEmpty) landmark,
      if (city != null && city!.isNotEmpty) city!,
      state,
      pincode,
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }
}
