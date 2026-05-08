import 'package:flutter/material.dart';

/// Centralized navigation to Login when auth is invalid.
/// Safe to call from anywhere (e.g. Dio interceptor) without BuildContext.
///
/// Must be initialized at app startup with [init].
/// Call [clearLoginNavigationFlag] when user leaves the Login screen (e.g. Skip/Back
/// or system back) or after successful login so the next session expiry can navigate again.
class AuthNavigationService {
  AuthNavigationService._();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static MaterialPageRoute Function({String? redirectPath})? _loginRouteBuilder;
  static bool _didNavigateToLogin = false;

  /// Optional: provides current "path" when redirecting to login (for return-after-login).
  static String? Function()? _currentPathProvider;

  /// Optional: navigates to a path after login (e.g. back to Combo PDP).
  static void Function(String path)? _navigateToPath;

  /// Manually set by screens (e.g. in initState) so interceptor can pass it to login.
  static String? _currentPath;

  /// Initialize with the app's navigator key and a factory for the Login route.
  /// [loginRouteBuilder] receives an optional [redirectPath] to return to after login.
  /// [currentPathProvider] is used when [navigateToLogin] is called without [fromPath].
  /// [navigateToPath] is called after successful login when [redirectPath] was set.
  static void init(
    GlobalKey<NavigatorState> navigatorKey,
    MaterialPageRoute Function({String? redirectPath}) loginRouteBuilder, {
    String? Function()? currentPathProvider,
    void Function(String path)? navigateToPath,
  }) {
    _navigatorKey = navigatorKey;
    _loginRouteBuilder = loginRouteBuilder;
    _currentPathProvider = currentPathProvider;
    _navigateToPath = navigateToPath;
  }

  /// Set the current "path" (e.g. "combo:productID") so the interceptor can pass it to login.
  /// Call from initState of screens that should be returnable after login; clear in dispose.
  static void setCurrentPath(String? path) {
    _currentPath = path;
  }

  /// Navigate to Login by replacing the entire stack.
  /// Idempotent: only the first call in a given "session invalid" period runs;
  /// further calls are no-ops until [clearLoginNavigationFlag] is called.
  /// [fromPath] is the path to return to after login; if null, uses [currentPath] or [currentPathProvider].
  static void navigateToLogin({String? fromPath}) {
    if (_didNavigateToLogin) return;
    final state = _navigatorKey?.currentState;
    if (state == null || _loginRouteBuilder == null) return;

    _didNavigateToLogin = true;
    final redirectPath =
        fromPath ?? _currentPath ?? _currentPathProvider?.call();
    state.pushAndRemoveUntil(
      _loginRouteBuilder!(redirectPath: redirectPath),
      (route) => false,
    );
  }

  /// Clear the "already navigated to login" flag. Call when the user leaves the Login
  /// screen (e.g. Skip/Back, system back via PopScope) or after successful login so
  /// that the next session expiry can trigger navigation again.
  static void clearLoginNavigationFlag() {
    _didNavigateToLogin = false;
  }

  /// Navigate to [path] after login (e.g. back to Combo PDP). No-op if [navigateToPath] was not set in [init].
  static void navigateToPath(String path) {
    _navigateToPath?.call(path);
  }

  /// Whether [navigateToPath] is configured.
  static bool get hasNavigateToPath => _navigateToPath != null;
}
