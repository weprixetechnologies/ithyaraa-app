class SignupData {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;
  final String? referCode;

  SignupData({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.referCode,
  });
}
