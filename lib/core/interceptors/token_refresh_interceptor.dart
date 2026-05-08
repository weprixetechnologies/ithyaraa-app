import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/entities/auth_tokens.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../navigation/auth_navigation_service.dart';

// ---------------------------------------------------------------------------
// Constants (shared for refresh-endpoint detection and extra keys)
// ---------------------------------------------------------------------------

/// Path of the refresh-token endpoint. Used to detect 401 from refresh so we
/// never trigger another refresh and instead logout + navigate immediately.
const String kRefreshEndpointPath = '/api/auth/refresh-token';

/// [RequestOptions.extra] keys used by this interceptor.
abstract class AuthInterceptorExtra {
  /// When true, the request requires auth: attach token; if missing, logout + navigate + reject.
  static const String requireAuth = 'requireAuth';

  /// When true, this request was already retried after a refresh. A 401 on it must not refresh again.
  static const String retriedAfterRefresh = 'retried_after_refresh';

  /// When set on a [DioException.requestOptions.extra], the UI can treat the error as session expiry.
  static const String sessionExpired = 'sessionExpired';
}

/// Normalizes path for comparison (trim trailing slashes, consistent slashes).
String _normalizePath(String path) {
  if (path.isEmpty) return path;
  return path.replaceAll(RegExp(r'/+$'), '').replaceAll(RegExp(r'^/+'), '/');
}

/// Returns true if [options] targets the refresh-token endpoint.
bool _isRefreshEndpoint(RequestOptions options) {
  final path = _normalizePath(options.uri.path);
  final expected = _normalizePath(kRefreshEndpointPath);
  return path == expected || path.endsWith(expected);
}

// ---------------------------------------------------------------------------
// TokenRefreshInterceptor
// ---------------------------------------------------------------------------

/// Auth interceptor: JWT refresh on 401, single global refresh, optional
/// explicit requireAuth, and centralized logout + navigation when session is invalid.
///
/// Behaviour:
/// - **onRequest:** If [AuthInterceptorExtra.requireAuth] is true, attach token
///   when present; if missing, logout + navigate to login + reject with session-expired.
///   If requireAuth is absent/false, backward-compatible: attach token when present.
/// - **onError (401):** If [retried_after_refresh] is true → logout, navigate, reject (no refresh).
///   If request is the refresh endpoint → logout, navigate, reject. Otherwise → one refresh,
///   then retry; on refresh failure/timeout or retry still 401 → single logout + navigate + reject.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(this.ref);

  final Ref ref;

  static Completer<AuthTokens?>? _refreshCompleter;
  static Future<AuthTokens?>? _refreshFuture;
  static bool _logoutTriggeredForCurrentRefresh = false;

  static const Duration _refreshTimeout = Duration(seconds: 30);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authState = ref.read(authProvider);
    final requireAuth = options.extra[AuthInterceptorExtra.requireAuth] == true;

    if (requireAuth) {
      // Pre-emptive: no token → cancel request and navigate to login (no network call).
      if (authState.accessToken == null || authState.accessToken!.isEmpty) {
        _logoutAndNavigateToLoginSync();
        final err = DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Session invalid: no access token',
        );
        handler.reject(_markSessionExpired(err));
        return;
      }
      options.headers['Authorization'] = 'Bearer ${authState.accessToken}';
    } else {
      // Backward-compatible: attach token when present
      if (authState.accessToken != null) {
        options.headers['Authorization'] = 'Bearer ${authState.accessToken}';
      }
    }
    handler.next(options);
  }

  /// Synchronous path: logout then navigate with current path (for onRequest).
  void _logoutAndNavigateToLoginSync() {
    ref.read(authProvider.notifier).logout().then((_) {
      AuthNavigationService.navigateToLogin();
    });
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Retried request still 401 → session invalid: logout, navigate (with path), reject.
    if (err.requestOptions.extra[AuthInterceptorExtra.retriedAfterRefresh] ==
        true) {
      await _logoutAndNavigateToLogin();
      return handler.next(_markSessionExpired(err));
    }

    // 401 from refresh endpoint → never refresh again; logout and navigate.
    if (_isRefreshEndpoint(err.requestOptions)) {
      await _logoutAndNavigateToLogin();
      return handler.next(_markSessionExpired(err));
    }

    // Single refresh for all concurrent 401s
    Future<AuthTokens?>? refreshFuture;
    if (_refreshFuture != null) {
      refreshFuture = _refreshFuture;
    } else {
      _refreshCompleter = Completer<AuthTokens?>();
      _refreshFuture = _refreshCompleter!.future;
      refreshFuture = _refreshFuture;
      _performRefresh();
    }

    try {
      final newTokens = await refreshFuture!.timeout(
        _refreshTimeout,
        onTimeout: () {
          throw TimeoutException('Token refresh timed out', _refreshTimeout);
        },
      );

      if (newTokens != null) {
        return _retryRequest(
          err.requestOptions,
          newTokens.accessToken,
          handler,
        );
      } else {
        throw Exception('Refresh returned null tokens');
      }
    } on TimeoutException {
      await _logoutAndNavigateToLogin();
      return handler.next(_markSessionExpired(err));
    } catch (e) {
      await _logoutAndNavigateToLogin();
      return handler.next(_markSessionExpired(_toDioException(err, e)));
    }
  }

  /// One logout + one navigation per refresh cycle; resets with completer.
  /// Uses current path from AuthNavigationService so login can return user to the same screen.
  Future<void> _logoutAndNavigateToLogin() async {
    if (_logoutTriggeredForCurrentRefresh) return;
    _logoutTriggeredForCurrentRefresh = true;
    await ref.read(authProvider.notifier).logout();
    AuthNavigationService.navigateToLogin();
  }

  DioException _markSessionExpired(DioException err) {
    final extra = Map<String, dynamic>.from(err.requestOptions.extra);
    extra[AuthInterceptorExtra.sessionExpired] = true;
    return err.copyWith(
      requestOptions: err.requestOptions.copyWith(extra: extra),
    );
  }

  DioException _toDioException(DioException original, Object error) {
    if (error is DioException) return error;
    return DioException(
      requestOptions: original.requestOptions,
      error: error,
      type: DioExceptionType.unknown,
    );
  }

  Future<void> _performRefresh() async {
    try {
      final notifier = ref.read(authProvider.notifier);
      final tokens = await notifier.refreshToken();
      _refreshCompleter?.complete(tokens);
    } catch (e) {
      _refreshCompleter?.completeError(e);
    } finally {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_refreshCompleter != null) {
          _refreshCompleter = null;
          _refreshFuture = null;
          _logoutTriggeredForCurrentRefresh = false;
        }
      });
    }
  }

  Future<void> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    final retryHeaders = {
      ...requestOptions.headers,
      'Authorization': 'Bearer $accessToken',
    };
    final retryExtra = Map<String, dynamic>.from(requestOptions.extra)
      ..[AuthInterceptorExtra.retriedAfterRefresh] = true;

    final baseOpts = BaseOptions(
      baseUrl: requestOptions.baseUrl,
      connectTimeout: requestOptions.connectTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      validateStatus: requestOptions.validateStatus,
      extra: retryExtra,
      headers: retryHeaders,
    );

    final retryOptions = Options(
      method: requestOptions.method,
      headers: retryHeaders,
      extra: retryExtra,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      listFormat: requestOptions.listFormat,
    );

    final dio = Dio(baseOpts);

    try {
      final response = await dio.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: retryOptions,
        cancelToken: requestOptions.cancelToken,
      );
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(
          DioException(
            requestOptions: requestOptions,
            error: e,
            type: DioExceptionType.unknown,
          ),
        );
      }
    }
  }
}
