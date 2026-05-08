import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_usecase.dart';
import '../providers/auth_provider.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  LoginState({this.isLoading = false, this.error, this.isSuccess = false});

  LoginState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUseCase loginUseCase;
  final AuthNotifier authNotifier;

  LoginNotifier({required this.loginUseCase, required this.authNotifier})
    : super(LoginState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final tokens = await loginUseCase(phone, password);
      await authNotifier.setTokens(tokens);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = LoginState();
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(
    loginUseCase: ref.read(loginUseCaseProvider),
    authNotifier: ref.read(authProvider.notifier),
  );
});
