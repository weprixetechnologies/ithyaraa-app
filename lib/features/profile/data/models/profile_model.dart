import '../../domain/entities/profile.dart';

/// Profile model (data layer)
///
/// Maps API response to domain entity
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.username,
    required super.name,
    required super.emailID,
    required super.phonenumber,
    super.profilePhoto,
    super.verifiedEmail,
    super.verifiedPhone,
    super.customAttributes,
  });

  /// Create from JSON response
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle verifiedEmail and verifiedPhone - can be int (0/1), bool, or null
    final verifiedEmail = json['verifiedEmail'];
    final verifiedPhone = json['verifiedPhone'];

    bool isEmailVerified = false;
    if (verifiedEmail != null) {
      if (verifiedEmail is bool) {
        isEmailVerified = verifiedEmail;
      } else if (verifiedEmail is int) {
        isEmailVerified = verifiedEmail == 1;
      }
    }

    bool isPhoneVerified = false;
    if (verifiedPhone != null) {
      if (verifiedPhone is bool) {
        isPhoneVerified = verifiedPhone;
      } else if (verifiedPhone is int) {
        isPhoneVerified = verifiedPhone == 1;
      }
    }

    return ProfileModel(
      uid: json['uid'] as String? ?? '',
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emailID: json['emailID'] as String? ?? '',
      phonenumber: json['phonenumber'] as String? ?? '',
      profilePhoto: json['profilePhoto'] as String?,
      verifiedEmail: isEmailVerified,
      verifiedPhone: isPhoneVerified,
      customAttributes: json['customAttributes'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON for update requests
  Map<String, dynamic> toJson() {
    return {
      if (name.isNotEmpty) 'name': name,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
    };
  }

  /// Create a copy with updated fields
  ProfileModel copyWith({
    String? uid,
    String? username,
    String? name,
    String? emailID,
    String? phonenumber,
    String? profilePhoto,
    bool? verifiedEmail,
    bool? verifiedPhone,
    Map<String, dynamic>? customAttributes,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      name: name ?? this.name,
      emailID: emailID ?? this.emailID,
      phonenumber: phonenumber ?? this.phonenumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      verifiedEmail: verifiedEmail ?? this.verifiedEmail,
      verifiedPhone: verifiedPhone ?? this.verifiedPhone,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }
}
