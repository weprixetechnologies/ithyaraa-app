import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../providers/auth_provider.dart';

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.read(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.read(authRepositoryProvider));
});

final createUserUseCaseProvider = Provider<CreateUserUseCase>((ref) {
  return CreateUserUseCase(ref.read(authRepositoryProvider));
});

class SignupState {
  final bool isLoading;
  final String? error;
  final bool isOtpSent;
  final bool isOtpVerified;
  final bool isUserCreated;

  SignupState({
    this.isLoading = false,
    this.error,
    this.isOtpSent = false,
    this.isOtpVerified = false,
    this.isUserCreated = false,
  });

  SignupState copyWith({
    bool? isLoading,
    String? error,
    bool? isOtpSent,
    bool? isOtpVerified,
    bool? isUserCreated,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      isUserCreated: isUserCreated ?? this.isUserCreated,
    );
  }
}

class SignupNotifier extends StateNotifier<SignupState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final CreateUserUseCase createUserUseCase;
  final AuthNotifier authNotifier;

  SignupNotifier({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.createUserUseCase,
    required this.authNotifier,
  }) : super(SignupState());

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await sendOtpUseCase(phoneNumber);
      state = state.copyWith(isLoading: false, isOtpSent: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await verifyOtpUseCase(phoneNumber, otp);
      state = state.copyWith(isLoading: false, isOtpVerified: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
    String? referCode,
  }) async {
    if (!state.isOtpVerified) {
      state = state.copyWith(error: 'OTP must be verified first');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, isUserCreated: false);
    try {
      final tokens = await createUserUseCase(
        name: name,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        referCode: referCode,
      );
      await authNotifier.setTokens(tokens);
      state = state.copyWith(isLoading: false, isUserCreated: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isUserCreated: false,
      );
    }
  }

  void reset() {
    state = SignupState();
  }
}

final signupProvider = StateNotifierProvider<SignupNotifier, SignupState>((ref) {
  return SignupNotifier(
    sendOtpUseCase: ref.read(sendOtpUseCaseProvider),
    verifyOtpUseCase: ref.read(verifyOtpUseCaseProvider),
    createUserUseCase: ref.read(createUserUseCaseProvider),
    authNotifier: ref.read(authProvider.notifier),
  );
});
