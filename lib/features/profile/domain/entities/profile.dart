/// Profile entity (domain layer)
///
/// Represents user profile data
class ProfileEntity {
  final String uid;
  final String username;
  final String name;
  final String emailID;
  final String phonenumber;
  final String? profilePhoto;
  final bool verifiedEmail;
  final bool verifiedPhone;
  final Map<String, dynamic>? customAttributes;

  const ProfileEntity({
    required this.uid,
    required this.username,
    required this.name,
    required this.emailID,
    required this.phonenumber,
    this.profilePhoto,
    this.verifiedEmail = false,
    this.verifiedPhone = false,
    this.customAttributes,
  });
}
