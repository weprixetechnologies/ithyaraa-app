import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Core auth state provider
/// 
/// Provides a simple interface to check authentication status
/// This wraps the existing auth provider for core-level access
final authStateProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoggedIn;
});

/// Auth status enum for clearer state management
enum AuthStatus {
  authenticated,
  unauthenticated,
}

/// Auth status provider
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoggedIn 
      ? AuthStatus.authenticated 
      : AuthStatus.unauthenticated;
});
