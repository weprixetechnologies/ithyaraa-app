# TokenRefreshInterceptor — Usage & requireAuth

## Logout & navigation trigger points

Navigation to Login happens **exactly once** per "session invalid" period (idempotent via `AuthNavigationService`). Logout + navigate are triggered in these cases:

| Trigger | When |
|--------|------|
| **requireAuth + no token** | Request has `extra['requireAuth'] == true` but user has no access token. |
| **Retried request still 401** | Request was already retried after a refresh and still got 401. |
| **401 from refresh endpoint** | The failed request was to the refresh-token endpoint (path normalized, no exact string match). |
| **Refresh token fails** | Refresh call threw (e.g. refresh token expired). |
| **Refresh timeout** | Refresh did not complete within the timeout (30s). |

After successful login, `AuthNavigationService.clearLoginNavigationFlag()` is called (from `main.dart` when auth state becomes logged in) so the next session expiry can navigate again.

## requireAuth for feature Dios

- **Default (backward-compatible):** If you do **not** set `requireAuth`, the interceptor attaches the access token to **every** request when a token is present (same as before).
- **Explicit private-only:** Set `extra['requireAuth'] = true` on requests that **must** be authenticated. Then:
  - If token is present → `Authorization: Bearer <token>` is attached.
  - If token is missing → logout, navigate to Login, and the request is rejected with a session-expired–marked error.

### How to set requireAuth

Use `Options(extra: {...})` when calling Dio so the interceptor sees it:

```dart
import 'package:dio/dio.dart';
import '../../../../core/interceptors/token_refresh_interceptor.dart';

// In your datasource or repository:
final response = await dio.get(
  '/api/user/detail-by-user',
  options: Options(extra: {AuthInterceptorExtra.requireAuth: true}),
);
```

For POST/PUT with body:

```dart
await dio.post(
  '/api/profile/update',
  data: body,
  options: Options(extra: {AuthInterceptorExtra.requireAuth: true}),
);
```

Feature Dios that already use `TokenRefreshInterceptor` (profile, cart, order, address) are the right place to add `requireAuth: true` for endpoints that must be authenticated. You can add it gradually; unset/absent still means "attach token when present".

## UI: detecting session-expired errors

When the interceptor rejects or forwards an error after logout/navigate, it marks the error so the UI can show a specific message:

```dart
try {
  await someAuthenticatedCall();
} on DioException catch (e) {
  if (e.requestOptions.extra[AuthInterceptorExtra.sessionExpired] == true) {
    // Session expired; user is already navigated to Login
    // Optionally show: "Your session expired. Please sign in again."
    return;
  }
  // Handle other errors (network, server, etc.)
}
```

## Retry-loop prevention (summary)

1. **Retried requests** are marked with `extra['retried_after_refresh'] = true`.
2. If such a request gets **401**, the interceptor does **not** refresh again; it logs out, navigates to Login, and rejects with a session-expired error.
3. **Refresh endpoint** is detected via normalized path (not exact string), so a 401 from the refresh call never triggers another refresh; it always logs out and navigates.
4. Only **one** refresh runs at a time (static `Completer`/`Future`); all concurrent 401s wait on the same future and then retry with the new token. Only one logout + navigate happens per refresh failure (static guard).
