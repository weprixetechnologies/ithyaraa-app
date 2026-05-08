import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class CreateUserUseCase {
  final AuthRepository repository;

  CreateUserUseCase(this.repository);

  Future<AuthTokens> call({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
    String? referCode,
  }) {
    return repository.createUser(
      name: name,
      phone: phone,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      referCode: referCode,
    );
  }
}
