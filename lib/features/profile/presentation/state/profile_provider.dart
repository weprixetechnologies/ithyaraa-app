import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_state_provider.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../providers/profile_api_providers.dart';

/// User profile model (UI layer)
///
/// Simplified model for UI consumption
/// Maps from domain ProfileEntity
class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String? imageUrl;
  final bool verifiedEmail;
  final bool verifiedPhone;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    this.imageUrl,
    this.verifiedEmail = false,
    this.verifiedPhone = false,
  });

  /// Create from domain entity
  factory UserProfile.fromEntity(ProfileEntity entity) {
    return UserProfile(
      name: entity.name,
      email: entity.emailID,
      phone: entity.phonenumber,
      imageUrl: entity.profilePhoto,
      verifiedEmail: entity.verifiedEmail,
      verifiedPhone: entity.verifiedPhone,
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    bool? verifiedEmail,
    bool? verifiedPhone,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      verifiedEmail: verifiedEmail ?? this.verifiedEmail,
      verifiedPhone: verifiedPhone ?? this.verifiedPhone,
    );
  }
}

/// Profile state
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Profile notifier
///
/// Manages profile state
/// Fetches profile data from API when user is authenticated
class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileNotifier({
    required bool isAuthenticated,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileState(isLoading: true)) {
    // Only initialize if user is authenticated
    if (isAuthenticated) {
      _fetchProfile();
    } else {
      state = const ProfileState(isLoading: false);
    }
  }

  /// Fetch profile from API
  Future<void> _fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileEntity = await getProfileUseCase();

      if (!mounted) return;

      final userProfile = UserProfile.fromEntity(profileEntity);

      state = ProfileState(profile: userProfile, isLoading: false, error: null);
    } catch (e) {
      print('[ProfileNotifier] Error fetching profile: $e');
      state = ProfileState(
        profile: null,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Initialize profile (public method for provider access)
  Future<void> initializeProfile() async {
    if (state.profile == null && !state.isLoading) {
      await _fetchProfile();
    }
  }

  /// Update profile (for edit profile feature)
  Future<void> updateProfile({String? name, String? profilePhoto}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedEntity = await updateProfileUseCase(
        name: name,
        profilePhoto: profilePhoto,
      );

      if (!mounted) return;

      final userProfile = UserProfile.fromEntity(updatedEntity);

      state = ProfileState(profile: userProfile, isLoading: false, error: null);
    } catch (e) {
      print('[ProfileNotifier] Error updating profile: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Clear profile (e.g., on logout)
  void clearProfile() {
    state = const ProfileState();
  }
}

/// Profile provider
///
/// Provides profile state to the app
/// Only fetches/initializes when user is authenticated
///
/// Note: Profile is fetched once at app start (not on every tab switch)
/// The notifier initializes automatically when first accessed
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final authStatus = ref.watch(authStatusProvider);
  final isAuthenticated = authStatus == AuthStatus.authenticated;

  // Get use cases
  final getProfileUseCase = ref.read(getProfileUseCaseProvider);
  final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);

  // Only initialize profile if user is authenticated
  final notifier = ProfileNotifier(
    isAuthenticated: isAuthenticated,
    getProfileUseCase: getProfileUseCase,
    updateProfileUseCase: updateProfileUseCase,
  );

  // Clear profile if user logs out, initialize if user logs in
  // ref.listen removed as ref.watch handles recreation
  // and initialization/clearing via constructor arguments

  return notifier;
});
