import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({required this.apiService, required this.secureStorage});

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await apiService.sendOtp(phoneNumber);
  }

  @override
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    await apiService.verifyOtp(phoneNumber, otp);
  }

  @override
  Future<AuthTokens> createUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
    String? referCode,
  }) async {
    final response = await apiService.createUser(
      name: name,
      phonenumber: phone,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      referCode: referCode,
    );

    // Parse create-user response (does not contain tokens)
    final success = response['success'] as bool?;
    if (success != true) {
      throw Exception(response['message'] as String? ?? 'User creation failed');
    }

    // Validate response contains expected fields
    final uid = response['uid'];
    final username = response['username'];
    if (uid == null || username == null) {
      throw Exception('Invalid response: missing uid or username');
    }

    // After successful signup, login to get tokens
    // This maintains the domain contract while matching API behavior
    return await login(phone, password);
  }

  @override
  Future<AuthTokens> login(String phone, String password) async {
    final response = await apiService.login(phone, password);

    // Parse tokens as nullable first to avoid force cast errors
    final accessToken = response['accessToken'] as String?;
    final refreshToken = response['refreshToken'] as String?;

    // Validate tokens are present
    if (accessToken == null || refreshToken == null) {
      throw Exception('Authentication failed: missing tokens in response');
    }

    // Validate tokens are not empty
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw Exception('Authentication failed: invalid tokens in response');
    }

    final tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await saveTokens(tokens);
    return tokens;
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await apiService.refreshToken(refreshToken);

    // Parse tokens as nullable first
    final accessToken = response['accessToken'] as String?;
    final newRefreshToken = response['refreshToken'] as String?;

    // Validate tokens are present
    if (accessToken == null || newRefreshToken == null) {
      throw Exception('Token refresh failed: missing tokens in response');
    }

    // Validate tokens are not empty
    if (accessToken.isEmpty || newRefreshToken.isEmpty) {
      throw Exception('Token refresh failed: invalid tokens in response');
    }

    final tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );

    // Automatically save new tokens
    await saveTokens(tokens);
    return tokens;
  }

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await secureStorage.saveAccessToken(tokens.accessToken);
    if (tokens.refreshToken != null) {
      await secureStorage.saveRefreshToken(tokens.refreshToken!);
    }
  }

  @override
  Future<AuthTokens?> getStoredTokens() async {
    final accessToken = await secureStorage.getAccessToken();
    final refreshToken = await secureStorage.getRefreshToken();

    if (accessToken != null) {
      return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
    }
    return null;
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.clearAll();
  }
}
