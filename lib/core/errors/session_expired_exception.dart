/// Thrown when the server returns 401 or auth is invalid and the user
/// is being redirected to login. Controllers should catch this and avoid
/// showing an error snackbar (navigation handles the UX).
class SessionExpiredException implements Exception {
  final String? message;

  SessionExpiredException([this.message]);

  @override
  String toString() => message ?? 'Session expired';
}
