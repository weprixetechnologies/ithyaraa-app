import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthTokens> call(String phone, String password) {
    return repository.login(phone, password);
  }
}
