/// Centralized keys used for secure storage.
///
/// This avoids hardcoding strings across the application
/// and prevents typos when accessing stored values.
class StorageKeys {
  StorageKeys._();

  /// Key used to store the JWT access token.
  static const String accessToken = 'access_token';

  /// Key used to store the JWT refresh token.
  static const String refreshToken = 'refresh_token';

  /// Key used to store serialized user information (optional).
  static const String user = 'auth_user';
}
