import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<ProfileEntity> call({
    String? name,
    String? profilePhoto,
  }) async {
    return await repository.updateProfile(
      name: name,
      profilePhoto: profilePhoto,
    );
  }
}
