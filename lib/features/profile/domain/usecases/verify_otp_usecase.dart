import '../repositories/profile_repository.dart';

/// Use case for verifying OTP
class VerifyOtpUseCase {
  final ProfileRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<void> call(String identifier, String otp) async {
    return await repository.verifyOtp(identifier, otp);
  }
}
