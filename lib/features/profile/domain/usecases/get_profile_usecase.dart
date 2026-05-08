import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting user profile
class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<ProfileEntity> call() async {
    return await repository.getProfileDetails();
  }
}
