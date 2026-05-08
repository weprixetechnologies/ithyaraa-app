import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<void> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}
