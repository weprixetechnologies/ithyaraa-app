import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../data/services/secure_storage_service.dart';
import 'package:flutter/foundation.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiService: ref.read(apiServiceProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final bool isLoggedIn;

  AuthState({this.accessToken, this.refreshToken, this.isLoggedIn = false});

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    bool? isLoggedIn,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  bool _isLoading = false;

  AuthNotifier(this.repository) : super(AuthState()) {
    // Load tokens from secure storage on initialization
    _loadStoredTokens();
  }

  /// Load tokens from secure storage and update state
  /// Called automatically on app startup
  Future<void> _loadStoredTokens() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final tokens = await repository.getStoredTokens();
      if (tokens != null && tokens.accessToken.isNotEmpty) {
        // Access token found, restore state
        state = AuthState(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          isLoggedIn: true,
        );
        debugPrint(
          '[AuthNotifier] Authentication restored from secure storage',
        );
      } else {
        debugPrint('[AuthNotifier] No active session found');
      }
    } catch (e) {
      debugPrint('[AuthNotifier] Error loading tokens: $e');
      // On error, keep default state (not logged in)
    } finally {
      _isLoading = false;
    }
  }

  Future<void> setTokens(AuthTokens tokens) async {
    await repository.saveTokens(tokens);
    state = AuthState(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      isLoggedIn: true,
    );
  }

  Future<AuthTokens> refreshToken() async {
    final currentRefreshToken = state.refreshToken;
    if (currentRefreshToken == null) {
      throw Exception('No refresh token available');
    }

    final tokens = await repository.refreshToken(currentRefreshToken);
    // Update state with new tokens
    state = AuthState(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      isLoggedIn: true,
    );
    return tokens;
  }

  Future<void> loginWithSessionToken(String token) async {
    final tokens = AuthTokens(accessToken: token);
    await repository.saveTokens(tokens);
    state = AuthState(accessToken: token, isLoggedIn: true);
  }

  Future<void> logout() async {
    await repository.clearTokens();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
