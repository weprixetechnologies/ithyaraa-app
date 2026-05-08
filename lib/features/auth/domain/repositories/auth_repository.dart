import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phoneNumber);
  Future<void> verifyOtp(String phoneNumber, String otp);
  Future<AuthTokens> createUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
    String? referCode,
  });
  Future<AuthTokens> login(String phone, String password);
  Future<AuthTokens> refreshToken(String refreshToken);
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getStoredTokens();
  Future<void> clearTokens();
}
