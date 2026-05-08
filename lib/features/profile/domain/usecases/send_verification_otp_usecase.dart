import '../repositories/profile_repository.dart';

/// Use case for sending verification OTP
class SendVerificationOtpUseCase {
  final ProfileRepository repository;

  SendVerificationOtpUseCase(this.repository);

  Future<void> call(String identifier) async {
    return await repository.sendVerificationOtp(identifier);
  }
}
