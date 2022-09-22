/// Exception related to authentication
class AuthException implements Exception {
  final String message;

  const AuthException([this.message = 'Default message']);

  @override
  String toString() => 'AuthException: $message';
}
